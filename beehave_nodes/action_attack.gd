extends ActionLeaf

func tick(actor, blackboard):
	var enemy = actor.target_unit
	actor.rotate_to(enemy.global_position)
	
	#change anim to aiming
	actor.anim.aim(true)
	print("attacking!!!")
	return FAILURE
