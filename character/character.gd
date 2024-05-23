class_name Character extends Unit

enum { DEAD = -1, NORMAL, STEALTH, ALERT, COMBAT, DOWNED, SLEEP } 

signal detected
signal damaged

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var bt:BeehaveTree = $BeehaveTree
@onready var detectionHandler = $DetectionHandler
@onready var anim:AnimationController = %AnimationTree
@onready var weapons = %Weapon1
@onready var crosshair:RayCast3D = $crosshair
@onready var action_timer:Timer = $ActionTimer
@onready var headsUp = %CharacterHud
@onready var actions = $Actions

var is_turn:bool:
	get: return action_timer.time_left <= 0
var next_action:float = 2.0:
	set(val):
		next_action = max(val, 0)
		action_timer.wait_time = next_action

@export var visibility_range:float = 10.0
@export var walk_speed:float = 1.5
var current_state = NORMAL:
	set(value):
		#if current_state != value:
			#print(self.name," entered state: ", state.find_key(value))
		current_state = value
		anim.motion_y = current_state
var is_dead:bool = false:
	set(val):
		is_dead = val
		$CollisionShape3D.disabled = is_dead
		if is_dead:
			print(self.name, " died")
			current_state = DEAD
			process_mode = Node.PROCESS_MODE_DISABLED
@export var max_health:float = 10.0
var health:float = max_health:
	set(val):
		health = val
@export var starting_wpn:int=0
var equipped_weapon:Weapon:
	set(value):
		equipped_weapon = value
		if equipped_weapon:
			crosshair.target_position = crosshair.transform.basis.z * -equipped_weapon.range_
		#selected_action = default_action
var is_moving:bool = false:
	set(val):
		is_moving = val
		if is_moving: anim.move()
		else: anim.stop()
var target_vec = null:
	set(val):
		if val and val.length() > 0: 
			nav.target_position = val #to check at next line if its reachable
			#(!) still assigned value to nav.target_pos
			target_vec = nav.target_position if nav.is_target_reachable() else null
		else: 
			target_vec = null
		is_moving = target_vec != null
	get:
		return target_vec if target_vec != null else null
var target_unit:
	set(val):
		target_unit = val
		crosshair.enabled = target_unit != null
		current_state = ALERT if target_unit else NORMAL
		#(!) Do NOT change state to NORMAL if null - only when no enemies left in detection area
var stealth_active:bool = false:
	set(val):
		stealth_active = val
		current_state = STEALTH if stealth_active else NORMAL
		#set animation state
		headsUp.create_msg(str("Stealth ","ON" if stealth_active else "OFF"))

var starting_actions = []
@onready var default_action:Action = $Actions/Default
var selected_action:Action:
	set(value):
		selected_action = value if value != null else default_action
		selected_action.init()

func _ready() -> void:
	super._ready()
	
	for action in $Actions.get_children():
		starting_actions.append(action)
		action.actor = self
	selected_action = default_action
	
	anim.disarm()
	equip(weapons.get_child(starting_wpn))
	
	detectionHandler.unit = self
	detectionHandler.update_fov()
	next_action = 2
	Global.add_unit(self)
	Global.unit_died.connect(_on_unit_died)
	current_state = NORMAL
	
	health = max_health
	
	init_headsupd()


func _process(delta: float) -> void:
	headsUp.update_actionbar(action_timer.time_left,next_action)

func _physics_process(delta: float) -> void:
	if is_moving and is_turn:
		var dir = Vector3()
		dir = (nav.get_next_path_position() - self.global_position).normalized()
		velocity = dir * walk_speed
		move_and_slide()
		rotate_to(nav.get_next_path_position())
	
	if target_unit and team != Global.PLAYER_TEAM:
		if detectionHandler.check_visibility(target_unit):
			rotate_to(target_unit.global_position)


func end_turn():
	action_timer.start()

func rotate_to(_target:Vector3, rotation_speed:float = .2):
	if self.global_transform.origin.is_equal_approx(_target):
		return
	var new_transform = self.transform.looking_at(_target, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, rotation_speed)

func equip(new_wpn:Weapon):
	if equipped_weapon and equipped_weapon == new_wpn:
		anim.disarm()
		equipped_weapon.visible = false
		equipped_weapon = null
		return
	
	var wpns = weapons.get_children()
	for w in wpns:
		if w == new_wpn:
			w.visible = true
			equipped_weapon = w
			headsUp.create_msg(new_wpn.name_)
		else:
			w.visible = false
	
	anim.equip(new_wpn.type)
	default_action.update()


func select_action(action_key:String):
	for a in actions.get_children():
		if a.action_name == action_key:
			selected_action = a
			print(action_key, " selected")

func execute_action():
	selected_action.execute()
	selected_action = default_action


func take_damage(actor, dmg):
	health -= dmg
	headsUp.create_msg(str("-",dmg))
	damaged.emit()
	if health <= 0:
		Global.unit_died.emit(self)
		return
	
	if !target_unit:
		if team != Global.PLAYER_TEAM:
			end_turn()
			#TODO: units should be penalized in some way for escaping combat
			#if player end_turn everytime is hit it will stop walking every half second
			target_unit = actor
			if target_unit.stealth_active and detectionHandler.check_visibility(target_unit):
				target_unit.detected.emit()


func set_unconsious():
	print(self.name, " is unconsious")
	current_state = SLEEP
	process_mode = Node.PROCESS_MODE_DISABLED


func _on_unit_died(unit):
	if unit == self: 
		self.is_dead = true
		Global.remove_unit(unit)
	if target_unit == unit:
		target_unit = null

## the var target only updates by the user input (command) so this func can be used to check if a new target was selected by the user or the ai ;)
func _on_target_updated(new_target) -> void:
	if !is_enemy(new_target.collider):
		target_unit = null
		target_vec = new_target.position
	else:
		target_unit = new_target.collider

func _on_nav_target_reached() -> void:
	target_vec = null


func _on_nav_velocity_computed(safe_velocity: Vector3) -> void:
	pass # Replace with function body.


func _on_detected() -> void:
	if stealth_active: stealth_active = false
	headsUp.create_msg("DETECTED")


func init_headsupd():
	headsUp.set_charname(self.name)
	$Sprite3D.texture = %SubViewport.get_texture()
