extends State
class_name Alert

var timer

func enter():
	timer = 1.0


func update(delta:float):
	if !target_char || target_char.is_dead:
		return
	timer -= delta
	if target_pos != Vector3.ZERO:
		target_char = null
		return
	
	if timer > 0:
		if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
			changed.emit('combat')
	else:
		timer = 1.0
		changed.emit('follow')
