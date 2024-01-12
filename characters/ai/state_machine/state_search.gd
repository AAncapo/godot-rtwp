class_name Search extends State

var last_target_pos:Vector3


func enter():
	super.enter()
	last_target_pos = target.global_position
	character.mov.move_to(last_target_pos)


func update_physics(_delta:float):
	if !target || target.dead: return
	
	if character.at_range_from(target) && character.da.is_inside_fov(target):
		if !character.ai_enabled: changed.emit('combat',target)
		else: changed.emit('cover',target)
		return
	
	if character.mov.is_target_reached() && !character.da.is_inside_fov(target):
		changed.emit('idle')
		return
