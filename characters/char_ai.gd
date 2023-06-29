extends Node3D

@onready var _char : Character = get_parent()
@onready var mov: CharacterMovement = $Movement
@onready var wpn_controller: WeaponController = $WeaponController
@onready var detectArea: DetectionArea = $DetectionArea
@onready var ai_enabled: bool = _char.team != 0

### HOW IT WORKS ###
# all states get access to movement, wpnCtrl & character nodes at ready()
# the targets (char/pos) are assigned in their setters
# before starting a new state load_state() sets all the main nodes props

@export var initial_state: State
@onready var stateMachine = $States
var states: Dictionary = {}
var current_state: State:
	set(new_state):
		if current_state:
			current_state.exit()
		new_state.enter()
		current_state = new_state

var target_char: Character:
	set(value):
		if value != null:
			target_pos = Vector3.ZERO
		target_char = value
		for state in stateMachine.get_children():
			state.target_char = value
var target_pos: Vector3:
	set(value):
		target_pos = value
		for state in stateMachine.get_children():
			state.target_pos = value

var rungun: bool:
	set(value):
		rungun = value
		if !rungun:
			target_char = null
		for state in stateMachine.get_children():
			state.rungun = value


func _ready():
	mov._char = _char
	detectArea.radius = _char.detection_range
	
	######### init state machine ###########
	for child in stateMachine.get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.changed.connect(change_state)
			child._char = _char
			child.mov = mov
			child.wpn_ctrl = wpn_controller
			child.da = detectArea
	if initial_state:
		current_state = initial_state
	########################################
	GameEvents.character_died.connect(_on_character_died)


func _process(delta):
	if current_state:
		current_state.update(delta)

func _physics_process(delta):
	if current_state:
		current_state.update_physics(delta)


func change_state(new_state_name:String):
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		print('ERROR: Cannot find a State.',new_state_name)
		new_state = states.get('idle')
	
	var mov_spd: float
	var safe_dist: float
	match new_state_name:
		'idle':
			pass
		'wander':
			pass
		'follow':
			mov_spd = _char.alert_spd
			safe_dist = _char.base_safe_dist
		'alert':
			mov_spd = _char.alert_spd
			safe_dist = _char.base_safe_dist
		'combat':
			mov_spd = _char.alert_spd
			safe_dist = _char.optimal_hr
		'interact':
			mov_spd = _char.run_spd
			safe_dist = _char.interact_range
		'move':
			mov_spd = _char.run_spd
			safe_dist = _char.base_safe_dist
	
	if mov_spd > 0 && safe_dist > 0:
		mov.move_speed = mov_spd
		_char.safe_dist = safe_dist
	GameEvents.update_clg.emit(_char,str('entered ',new_state.name,' state'),_char)
	
	current_state = new_state


func _on_character_target_updated(new_target, force_to:bool):
	if new_target is CollisionObject3D:
		#if player dbl_clck run&gun is disabled
		rungun = !force_to
		target_char = new_target
		
		if !_char.is_enemy(new_target):
			current_state.changed.emit('interact')  #or interact idk
		else:
			#at_range?
			if _char.at_range_from(new_target):
				current_state.changed.emit('alert') #is_inside_fov?
			else:
				current_state.changed.emit('follow')
	
	## the new target is a position vector
	if new_target is Vector3:
		target_pos = new_target
#		print(target_pos)
		rungun = !force_to
		
		_char.safe_dist = _char.base_safe_dist
		mov.move_speed = _char.alert_spd
		if !rungun:
			current_state.changed.emit('move')
#			print(target_pos)
			return
		mov.move_to(new_target)


func _on_weapon_controller_equipped(new_equipped_wpn:Weapon):
	_char.hit_range = new_equipped_wpn.wpn_range
	new_equipped_wpn.wpn_owner = _char


func _on_character_died(_character):
	if target_char && _character == target_char:
		target_char = null


############# AI ENABLED ONLY #############
func _on_detection_area_body_entered(body):
	if target_char:
		return
	if ai_enabled && _char.is_enemy(body):
		target_char = body
		GameEvents.update_clg.emit(_char,'feels something kinda sus',body)
		if _char.at_range_from(body):
			current_state.changed.emit('alert') #is_inside_fov?
		else:
			current_state.changed.emit('follow')

func _on_detection_area_body_exited(body):
	if ai_enabled && _char.is_enemy(body):
		if target_char && target_char==body:
			target_char = null
			## WANDER ##
			current_state.changed.emit('wander')
###########################################
