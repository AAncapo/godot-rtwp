extends ActionLeaf

func tick(actor, blackboard):
	var agent = actor.nav_agent
	var dir = Vector3()
	dir = (agent.get_next_path_position() - actor.global_position).normalized()
	actor.velocity = dir * actor.walk_speed
	actor.move_and_slide() #TODO: how to put this in a physics process
	
	if not actor.target.collider.is_in_group("units"): #TODO: and if is at range
		actor.rotate_to(agent.get_next_path_position())
	
	actor.anim.move()
	
	return FAILURE
