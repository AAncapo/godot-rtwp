class_name Move extends State


func enter():
	super.enter()
	character.mov.move_to(target)


func update(_delta:float):
	if character.mov.is_target_reached():
		changed.emit('idle')
		return
