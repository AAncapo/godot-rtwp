extends ActionLeaf

func tick(actor, blackboard):
	var enemy = actor.target.collider
	actor.rotate_to(enemy.global_position)
	
	#change anim to aiming
	actor.anim.aim()
	print("attacking!!!")
	return FAILURE
