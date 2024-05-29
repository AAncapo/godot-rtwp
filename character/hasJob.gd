extends ConditionLeaf

func tick(actor, blackboard):
	if actor.job and !actor.target_unit:
		if actor.current_state != Character.WORKING:
			actor.current_state = Character.WORKING
			actor.target_vec = actor.job.get_last_pos()
			#print(actor.name," get to work")
			return FAILURE
		
		if actor.current_state == Character.WORKING:
			return SUCCESS
	
	return FAILURE