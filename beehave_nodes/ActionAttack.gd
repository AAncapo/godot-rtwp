extends ActionLeaf


func tick(actor, blackboard):
	var target = actor.target_unit
	if target:
		actor.rotate_to(target.global_position)
		var is_looking_at_target = actor.crosshair.get_collider() == target
		
		actor.anim.aim(true) #TODO: esto pa otro lado
		
		if is_looking_at_target:
			actor.execute_action()
			actor.end_turn()
			print(actor.name," action executed")
			return SUCCESS
	return FAILURE
