extends Node3D

@onready var mov: CharacterMovement = $Movement
@onready var wpn_controller: WeaponController = $WeaponController
@onready var detectArea: DetectionArea = $DetectionArea
@onready var stateMachine = $StateMachine
@onready var _char:Character = get_parent()
@onready var ai_enabled: bool = _char.team != 0


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
	GameEvents.character_died.connect(_on_character_died)
	##### init state machine ####
	for child in stateMachine.get_children():
		child._char = _char
		child.mov = mov
		child.wpn_ctrl = wpn_controller
		child.da = detectArea
	#############################


func _on_character_target_updated(new_target, force_to:bool):
	if new_target is CollisionObject3D:
		#if player dbl_clck run&gun is disabled
		rungun = !force_to
		target_char = new_target
		
		if !_char.is_enemy(new_target):
			stateMachine.current_state.changed.emit('interact')
			pass
		else:
			#at_range?
			if _char.at_range_from(new_target):
				stateMachine.current_state.changed.emit('alert') #is_inside_fov?
				pass
			else:
				stateMachine.current_state.changed.emit('follow')
				pass
	## the new target is a position vector
	if new_target is Vector3:
		target_pos = new_target
#		print(target_pos)
		rungun = !force_to
		
		_char.safe_dist = _char.base_safe_dist
		mov.move_speed = _char.alert_spd
		if !rungun:
			stateMachine.current_state.changed.emit('move')
#			print(target_pos)
			return
		mov.move_to(new_target)


func _on_weapon_controller_equipped(new_equipped_wpn:Weapon):
	_char.hit_range = new_equipped_wpn.wpn_range
	new_equipped_wpn.wpn_owner = _char
	detectArea.radius = _char.hit_range


func _on_character_died(_character):
	if target_char && _character == target_char:
		target_char = null


############# AI ENABLED ONLY #############
func _on_detection_area_body_entered(body):
	if target_char:
		return
	if ai_enabled && _char.is_enemy(body):
		target_char = body
		if _char.at_range_from(body):
			stateMachine.current_state.changed.emit('alert') #is_inside_fov?
			pass
		else:
			stateMachine.current_state.changed.emit('follow')
			pass

func _on_detection_area_body_exited(body):
	if ai_enabled && _char.is_enemy(body):
		if target_char && target_char==body:
			target_char = null
			## WANDER ##
			stateMachine.current_state.changed.emit('wander')
			pass
###########################################
