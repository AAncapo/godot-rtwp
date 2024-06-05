extends ConditionLeaf


func tick(actor, _blackboard):
	#if actor.is_player() and actor.assignment == Character.Assignment.NONE:
		#return FAILURE
	
	#if has assignment but no current job
	if actor.assignment != 0 and !actor.current_job:
		actor.find_job()
	
	if actor.current_job and actor.current_state != Character.State.ALERT:
		if actor.current_state != Character.State.WORKING:
			actor.current_state = Character.State.WORKING
			actor.target_vec = actor.current_job.get_last_pos()
			return FAILURE
		
		if actor.current_state == Character.State.WORKING:
			return SUCCESS
	
	return FAILURE
