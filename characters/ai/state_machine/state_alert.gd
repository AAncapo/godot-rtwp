extends State
class_name Alert

var last_target_pos: Vector3

func enter():
	mov.move_speed = _char.alert_spd
	_char.safe_dist = _char.base_safe_dist
	
	last_target_pos = target_char.global_position


func update(delta:float):
	if !target_char || target_char.is_dead:
		return
	
	if target_pos != Vector3.ZERO:
		target_char = null
		return
	
	if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
		changed.emit('combat')


func update_physics(delta:float):
	mov.move_to(last_target_pos)
	
	## move to last known target position
	## search enemies in area
	## start wandering if nothing found
	if mov.has_reached_target():
		var enemies_in_area = da.get_units_in_area(_char)
		if enemies_in_area.size() > 0:
			_char.target = enemies_in_area[0]
			return
		changed.emit('wander')
