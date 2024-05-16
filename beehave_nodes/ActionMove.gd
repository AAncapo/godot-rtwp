extends ActionLeaf

func tick(actor, blackboard):
	actor.move_to(actor.target_vec, actor.walk_speed)
	
	return FAILURE
