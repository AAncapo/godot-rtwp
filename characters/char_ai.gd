extends Node3D

@onready var _char:Character = get_parent()
@onready var sm:StateMachine = $StateMachine


func _ready():
	GameEvents.character_died.connect(_on_character_died)


func _on_target_updated(new_target, player_input:bool):
	if !new_target: sm.curr_state.changed.emit('idle')
	
#	_char.ai_enabled = !player_input
	
	if new_target is CollisionObject3D:
		if new_target is CoverSpot:  #target is cover
			sm.curr_state.changed.emit('cover')
			sm.curr_state.curr_cspot = new_target
			return
		if !_char.is_enemy(new_target):  #target is ally unit
			sm.curr_state.changed.emit('interact',new_target)
		else:
			sm.curr_state.changed.emit('search',new_target)
	
	if new_target is Vector3:
		#target is a position
		sm.curr_state.changed.emit('move',new_target)
		#TODO: if rungun -> use mov.move_to directly?
#		mov.move_to(new_target)


func _on_weapon_controller_equipped(new_equipped_wpn:Weapon):
	_char.hit_range = new_equipped_wpn._range
	new_equipped_wpn.wpn_owner = _char


func _on_character_died(_character):
	if !_char.target is Vector3 && _character == _char.target:
		_char.set_target(null)
		if _char.ai_enabled:
			#search new targets
			var enemies_left = _char.da.get_units_in_area(true)
			if enemies_left.size() > 0:
				if _char.at_range_from(enemies_left[0]):
					_char.set_target(enemies_left[0])
		else:
			sm.curr_state.changed.emit('idle')


func _on_detection_area_body_entered(body):
	if !_char.ai_enabled: return
	
	if _char.is_enemy(body):
		if !_char.is_behind_cover:
			sm.curr_state.changed.emit('cover',body)
			_char.set_target(body, false)  #set unit.target without emitting the target_updated signal


func _on_detection_area_body_exited(_body):
#	if !ai_enabled: return
#
#	if _char.is_enemy(body):
#		if _char.target && _char.target == body:
#			pass
	pass


func _on_character_damaged(attacker,_curr_hp,_max_hp):
	if !_char.ai_enabled: return
	
	if (sm.curr_state.name != 'combat' 
	|| sm.curr_state.name != 'cover'):
		if attacker:
			print(_char.name,' under attack! Searching for cover..')
			sm.curr_state.changed.emit('cover',attacker)
