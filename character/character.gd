class_name Character extends Unit

signal detected(detected_by)
signal action_selected(_action)

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var anim:AnimationController = %AnimationTree
@onready var weapons = %Weapon1
@onready var crosshair:RayCast3D = $crosshair
@onready var ttimer:Timer = $TurnTimer
@onready var actions = $Actions
@onready var stats := $Stats

var is_turn:bool = true
var next_action:float = 2.0:
	set(val):
		next_action = max(val, 0)
		ttimer.wait_time = next_action

@export var visibility_range:float = 10.0
@export var walk_speed:float = 1.5
enum { DEAD = -1, NORMAL, STEALTH, ALERT, WORKING, COMBAT, DOWNED, SLEEP } 
var current_state = NORMAL:
	set(value):
		if value == current_state: return
		previous_state = current_state
		current_state = value
		
		#TODO: placeholder code to tell the takedown action when is available
		actions.get_child(2).set_available.emit(current_state == STEALTH)
		
		anim.motion_y = current_state
		#print(self.name," state changed to ", current_state)
var previous_state = NORMAL
@export var starting_wpn:int=0
var equipped_wpn:Weapon:
	set(value):
		equipped_wpn = value
		if equipped_wpn:
			crosshair.target_position = crosshair.transform.basis.z * -equipped_wpn.range_
var target_vec = null:
	set(val):
		if val and val.length() > 0:
			nav.target_position = val #to check at next line if its reachable
			#(!) still assigned value to nav.target_pos
			target_vec = nav.target_position if nav.is_target_reachable() else null
		else: 
			target_vec = null
	get:
		return target_vec if target_vec != null else null
var target_unit:
	set(val):
		target_unit = val
		crosshair.enabled = target_unit != null
		if !target_unit and current_state != STEALTH:
			current_state = NORMAL
		if !target_unit: anim.aim(false)
var is_moving:bool:
	set(value):
		is_moving = value
		if is_moving: anim.move()
		else: anim.stop()
@onready var default_action:Action = $Actions/Default
var selected_action:Action:
	set(value):
		selected_action = value if value != null else default_action
		selected_action.init()
		action_selected.emit(selected_action)

enum Assignment { NONE, PATROL }
@export var assigned_job:Assignment
var job


func _ready() -> void:
	super._ready()
	ttimer.timeout.connect(_on_turn_started)
	target_updated.connect(_on_target_updated)
	selected_action = default_action
	
	anim.disarm()
	
	next_action = 2
	Global.add_unit(self)
	Global.unit_died.connect(_on_unit_died)
	current_state = NORMAL
	
	end_turn()
	find_job() #iduno maybe find job while in turn can cause problem
	
	#await get_tree().create_timer(2)
	for a in actions.get_children():
		a.actor = self
	equip(weapons.get_child(1))


func _physics_process(_delta: float) -> void:
	is_moving = target_vec and is_turn
	if is_moving:
		var dir = Vector3()
		dir = (nav.get_next_path_position() - self.global_position).normalized()
		velocity = dir * walk_speed
		move_and_slide()
		rotate_to(nav.get_next_path_position())
	
	## look at target while visible
	if target_unit:
		if check_visibility(target_unit):
			rotate_to(target_unit.global_position)


func _on_turn_started():
	#save rolls
	if stats.is_dead: return
	
	if stats.at_death_door:
		var saved = Fnff.save_roll(stats, Fnff.DEATH_SAVE)
		if !saved: 
			Global.unit_died.emit(self)
			return
	
	is_turn = true
	
	## check if still stunned from previous turn
	if stats.is_stunned:
		var saved = Fnff.save_roll(stats, Fnff.STUN_SAVE)
		stats.is_stunned = !saved


func end_turn():
	is_turn = false
	ttimer.start()

func rotate_to(_target:Vector3, rotation_speed:float = .2):
	if self.global_transform.origin.is_equal_approx(_target):
		return
	var new_transform = self.transform.looking_at(_target, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, rotation_speed)


func check_visibility(_target):
	var vcheck:RayCast3D = %VisibilityChecker
	vcheck.look_at(_target.global_position)
	var length = (_target.global_position - self.global_position).length()
	vcheck.target_position.z = -length * 1.2
	vcheck.target_position.y = _target.scale.y/2
	vcheck.force_raycast_update()  # doesnt need to be enabled for this to work
	return vcheck.get_collider() == _target


func equip(new_wpn:Weapon):
	if equipped_wpn and equipped_wpn == new_wpn:
		anim.disarm()
		equipped_wpn.visible = false
		equipped_wpn = null
		return
	
	var wpns = weapons.get_children()
	for w in wpns:
		if w == new_wpn:
			w.visible = true
			equipped_wpn = w
		else:
			w.visible = false
	
	anim.equip(new_wpn.type)
	default_action.update()


func execute_action():
	#print("execute -> ",selected_action.action_name)
	selected_action.execute()


func attack(_target):
	var atk = Attack.new(self, _target, equipped_wpn)
	atk.calc_hit_chance()
	match atk.result:
		Attack.FAILED:
			msg(Global.POPUP_NOTIF.NORMAL,"Failed")
		Attack.FUMBLED:
			msg(Global.POPUP_NOTIF.NORMAL,"Fumbled")
		Attack.MISSED:
			msg(Global.POPUP_NOTIF.NORMAL,"Miss")
		Attack.SUCCEED:
			_target.take_damage(atk)


func take_damage(atk:Attack):
	## Alert from attack
	if team != Global.PLAYER_TEAM:
		if !target_unit && atk.actor:
			end_turn()
			target_unit = atk.actor
			#target_vec = atk.actor.global_position
	var dmg = stats.calc_damage(atk)
	msg(Global.POPUP_NOTIF.NORMAL,str("-",dmg.amount))
	#TODO: display status in log


func choke():
	anim.choke()

func get_choked(die:bool):
	anim.get_choked(die)

func set_unconsious():
	print(self.name, " is unconsious")
	current_state = SLEEP
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_unit_died(unit):
	if unit == self: 
		stats.is_dead = true
		anim.die()
		current_state = DEAD
		print(self.name, " died")
	
	if target_unit == unit:
		target_unit = null

## the var target only updates by the user input (command) so this func can be used to check if a new target was selected by the user or the ai ;)
func _on_target_updated(new_target) -> void:
	if !is_enemy(new_target.collider):
		if target_unit: target_unit = null
		target_vec = new_target.position
	else:
		target_unit = new_target.collider

func _on_nav_target_reached() -> void:
	target_vec = null


func _on_detected(detected_by:Character) -> void:
	if current_state == STEALTH: current_state = ALERT
	msg(Global.POPUP_NOTIF.NORMAL,"DETECTED")


func find_job():
	match assigned_job:
		Assignment.NONE:
			#remain idle
			pass
		Assignment.PATROL:
			#search patrol paths in scene
			var patrol_paths = get_tree().get_nodes_in_group("patrol_path")
			#if not occupied, occupy by actor and send to it
			for pp in patrol_paths:
				if !pp.is_in_group("occupied"):
					pp.add_to_group("occupied")
					job = Job.new(pp.get_children())
					#print(self.name, " has patrol job at ",pp.name)
					return
			#no patrol path found
			assigned_job = Assignment.NONE


func msg(pop, text="",remove=false):
	%CharaHud.add_notification(pop,text,remove)


func disable():
	$BeehaveTree.enabled = false
	%CharaHud.clear_notifications()
	process_mode = Node.PROCESS_MODE_DISABLED
