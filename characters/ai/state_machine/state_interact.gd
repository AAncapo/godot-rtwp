extends State
class_name Interact


func enter():
	mov.move_speed = _char.run_spd
	_char.safe_dist = _char.interact_range
	
	target_char.interact()
