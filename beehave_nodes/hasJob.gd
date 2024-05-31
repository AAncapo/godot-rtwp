extends ConditionLeaf

func tick(actor, blackboard):
	if actor.job and !actor.target_unit:
		if actor.current_state != actor.WORKING:
			actor.current_state = actor.WORKING
			actor.target_vec = actor.job.get_last_pos()
			#print(actor.name," get to work")
			return FAILURE
		
		if actor.current_state == actor.WORKING:
			return SUCCESS
	
	return FAILURE
