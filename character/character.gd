class_name Character extends Unit

signal selected_action_updated(_action)  #connected to character portrait
signal detected

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var anim:AnimationController = %AnimationTree
@onready var crosshair:RayCast3D = $crosshair
@onready var ttimer:Timer = $TurnTimer
@onready var actions := $Actions
@onready var stats := $Stats
@onready var inventory := $Inventory
@onready var equipment := $Equipment
@onready var bound_area := $BoundArea

var is_turn:bool = true
var next_action:float = 2.0:
	set(val):
		next_action = max(val, 0)
		ttimer.wait_time = next_action

## values edited to match the MotionState (AnimCtr)
enum State { DOWNED = -1, IDLE, WORKING, ALERT, COMBAT }
var current_state:State= State.IDLE:
	set(value):
		if value == current_state: return
		previous_state = current_state
		current_state = value
		if current_state == State.ALERT:
			$DetectedIcon/Label3D/AnimationPlayer.play("detect")
var previous_state
var stealth_on:bool = false:
	set(value):
		stealth_on = value
		anim.motion_state = anim.MotionState.CROUCH if stealth_on else anim.MotionState.NORMAL
		actions.get_action("takedown").set_enabled.emit(stealth_on)

var target_vec = null:
	set(val):
		if val and val.length() > 0:
			nav.target_position = val
			target_vec = nav.target_position if nav.is_target_reachable() else null
		else: 
			target_vec = null
		if is_player(): _update_vec_visual(target_vec)
	get: return target_vec if target_vec != null else null
var target_unit:Character:
	set(val):
		if target_unit: #Remove mark from previous target (if existed)
			if target_unit.team != Global.PLAYER_TEAM:
				target_unit.set_as_marked(false)
		target_unit = val
		crosshair.enabled = target_unit != null
		if target_unit:
			if target_unit.team != Global.PLAYER_TEAM:
				target_unit.set_as_marked(true)
			anim.motion_state = AnimationController.MotionState.ALERTED
			if selected_action != actions.get_action('takedown'):
				actions.get_action('attack').select()
		else:
			anim.aim(false)
			if !stealth_on:
				anim.motion_state = AnimationController.MotionState.NORMAL
				current_state = State.IDLE
var is_moving:bool:
	set(value):
		is_moving = value
		if is_moving:
			anim.move(is_running)
		else: anim.stop()
var is_running:bool:
	get:
		return is_player() and (current_state==0 or current_state==1) and !stealth_on
var selected_action:Action
#var is_leader:bool = false:
	#set(value):
		#is_leader = value
		#if is_player():
			#assignment = 0 if is_leader else 2
enum Assignment { NONE, PATROL, FOLLOW }
@export var assignment:Assignment
var current_job


func _ready() -> void:
	target_updated.connect(_on_target_updated)
	
	Global.add_unit(self)
	Global.unit_died.connect(_on_unit_died)
	
	actions.init(self)
	
	anim.disarm()
	actions.get_action("attack").icon = equipment.unarmed_icon
	actions.get_action("attack").range_ = equipment.unarmed_range
	crosshair.target_position = crosshair.transform.basis.z * -equipment.unarmed_range
	
	ttimer.timeout.connect(_on_turn_started)
	next_action = 1
	end_turn()


func _physics_process(_delta: float) -> void:
	is_moving = target_vec and is_turn
	if is_moving:
		var dir = Vector3()
		dir = (nav.get_next_path_position() - self.global_position).normalized()
		velocity = dir * stats.SPEED
		move_and_slide()
		rotate_to(nav.get_next_path_position())
	
	## look at target while visible
	if target_unit:
		if check_visibility(target_unit):
			rotate_to(target_unit.global_position)


func _on_action_selected(_action, _is_selected):
	selected_action = _action if _is_selected else null
	selected_action_updated.emit(selected_action)
	
	if is_player():
		bound_area.update_range_visual(selected_action.range_ if selected_action else 0)


func _on_turn_started():
	if stats.is_dead: return
	
	is_turn = true
	if stats.at_death_door:
		stats.roll_death_save()


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


func _on_reload_request():
	#equipped_wpn send a (signal)request when no ammo
	#gui.gd send the signal from his equipped_wpn reference
	equipment.equipped_wpn.actions.get_action("reload").select()


func attack(_target):
	var atk = Attack.new(self, _target)
	var hit = atk.calc_hit_chance()
	
	if hit: _target.take_damage(atk) 
	else: msg(Global.POPUP_NOTIF.NORMAL,"Miss")


func take_damage(atk:Attack):
	## Alert from attack
	if team != Global.PLAYER_TEAM:
		if !target_unit && atk.actor:
			end_turn()
			target_unit = atk.actor
	var dmg = stats.calc_damage(atk)
	msg(Global.POPUP_NOTIF.NORMAL,str("-",dmg.amount))
	#TODO: display status in log


func choke():
	anim.choke()

func get_choked(die:bool):
	anim.get_choked(die)


func _on_unit_died(unit):
	if unit == self: 
		stats.is_dead = true
		anim.die()
		disable()
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


func _on_detected() -> void:
	if stealth_on: stealth_on = false
	msg(Global.POPUP_NOTIF.NORMAL,"DETECTED")


func find_job():
	match assignment:
		Assignment.NONE:
			#remain idle
			pass
		Assignment.FOLLOW:
			current_job = Job.new()
		Assignment.PATROL:
			#search patrol paths in scene
			var patrol_paths = get_tree().get_nodes_in_group("patrol_path")
			#if not occupied, occupy by actor and send to it
			for pp in patrol_paths:
				if !pp.is_in_group("occupied"):
					pp.add_to_group("occupied")
					current_job = Job.new(pp.get_children())
					#print(self.name, " has patrol job at ",pp.name)
					return
			#no patrol path found
			assignment = Assignment.NONE


func msg(pop, text="",remove=false):
	bound_area.add_notification(pop,text,remove)


func set_as_marked(value:bool):
	bound_area.is_marked = value


func _update_vec_visual(pos):
	var pos_visual := $PositionIndicator
	var _anim := pos_visual.get_node("AnimationPlayer")
	if !pos:
		_anim.play("RESET")
	else:
		_anim.play('start')
		pos_visual.global_position = pos
		pos_visual.global_position.y = 0.05


func disable():
	$CollisionShape3D.disabled = true
	$BeehaveTree.enabled = false
	bound_area.clear_notifications()


func _on_equipment_updated(_item: Item, _set_equipped: bool) -> void:
	match _item.equipment_class:
		Item.EquipmentClass.WEAPON:
			if _set_equipped:
				anim.update_equipped(_item)
				actions.get_action("attack").icon = _item.icon
				actions.get_action("attack").range_ = _item.range_
				crosshair.target_position = crosshair.transform.basis.z * -_item.range_
				if !_item.reload_requested.is_connected(_on_reload_request):
					_item.reload_requested.connect(_on_reload_request)
				
				equipment.equip(_item)
			else:
				if _item.reload_requested.is_connected(_on_reload_request):
					_item.reload_requested.disconnect(_on_reload_request)
				anim.disarm()
				actions.get_action("attack").icon = equipment.unarmed_icon
				actions.get_action("attack").range_ = equipment.unarmed_range
				crosshair.target_position = crosshair.transform.basis.z * -equipment.unarmed_range
				
				equipment.unequip(_item)
	
	_item.is_equipped = _set_equipped
