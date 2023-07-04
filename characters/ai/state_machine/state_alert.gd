extends State
class_name Alert


func enter():
	mov.move_speed = _char.alert_spd
	_char.safe_dist = _char.base_safe_dist


func update(delta:float):
	if !target_char || target_char.is_dead:
		return
	
	if target_pos != Vector3.ZERO:
		target_char = null
		return
	
	mov.move_to(target_char.global_position)
	
	if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
		changed.emit('combat')
	
	if mov.target_reached:
		var enemies_in_area = da.get_units_in_area(_char)
		if enemies_in_area.size() > 0:
			_char.target = enemies_in_area[0]
			return
		changed.emit('wander')
