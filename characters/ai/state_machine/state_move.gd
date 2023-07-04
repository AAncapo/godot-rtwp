extends State
class_name Move

func enter():
	mov.move_speed = _char.run_spd
	_char.safe_dist = _char.base_safe_dist
	
	mov.move_to(target_pos)
