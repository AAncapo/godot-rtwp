extends Node3D

@onready var _char: Character = get_parent()
@onready var mov: CharacterMovement = $Movement
@onready var wpn_controller: WeaponController = $WeaponController
@onready var detectArea: DetectionArea = $DetectionArea
@onready var stateMachine:StateMachine = $StateMachine
@onready var ai_enabled: bool = _char.team != 0

### HOW IT WORKS ###
# all states get access to movement, wpnCtrl & character nodes at ready()
# the targets (char/pos) are assigned in their setters
# before starting a new state load_state() sets all the main nodes props


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
	###### init state machine ######
	for child in stateMachine.get_children():
		if child is State:
			child._char = _char
			child.mov = mov
			child.wpn_ctrl = wpn_controller
			child.da = detectArea
	################################
	GameEvents.character_died.connect(_on_character_died)


func _on_character_target_updated(new_target, force_to:bool):
	if new_target is CollisionObject3D:
		if new_target == target_char:
			return
		#if player dbl_clck run&gun is disabled
		rungun = !force_to
		target_char = new_target
		
		if !_char.is_enemy(new_target):
			stateMachine.current_state.changed.emit('interact')
		else:
			stateMachine.current_state.changed.emit('alert')
	
	## the new target is a position vector
	if new_target is Vector3:
		target_pos = new_target
		rungun = !force_to
		
		_char.safe_dist = _char.base_safe_dist
		mov.move_speed = _char.alert_spd
		if !rungun:
			stateMachine.current_state.changed.emit('move')
		mov.move_to(new_target)


func _on_weapon_controller_equipped(new_equipped_wpn:Weapon):
	_char.hit_range = new_equipped_wpn.wpn_range
	new_equipped_wpn.wpn_owner = _char


func _on_character_died(_character):
	if target_char && _character == target_char:
		target_char = null


func _on_detection_area_body_entered(body):
	if target_char:
		return
	if ai_enabled && _char.is_enemy(body):
		target_char = body
		stateMachine.current_state.changed.emit('alert')


func _on_detection_area_body_exited(body):
	if ai_enabled && _char.is_enemy(body):
		if target_char && target_char==body:
			pass


func _on_character_damaged(attacker, _cur_hp, _max_hp):
	if (stateMachine.current_state.name != 'combat' 
	|| stateMachine.current_state.name != 'move'
	|| stateMachine.current_state.name != 'alert'):
		if attacker:
			_char.target = attacker
