extends State
class_name Follow

func update_physics(_delta:float):
	if !target_char || target_char.is_dead || target_pos != Vector3.ZERO:
		return
	
	if da.is_inside_fov(target_char):
		changed.emit('alert')
	else:
		mov.move_to(target_char.global_position)
