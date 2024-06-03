extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.team == Global.PLAYER_TEAM:
		if Global.player_leader != actor: actor.assignment = Character.Assignment.FOLLOW
		else: actor.assignment = 0
	
	#if has job assigned but no current job
	if actor.assignment != 0 and !actor.current_job:
		actor.find_job()
	
	if actor.current_job and actor.current_state != Character.ALERT:
		if actor.current_state != actor.WORKING:
			actor.current_state = actor.WORKING
			actor.target_vec = actor.current_job.get_last_pos()
			return FAILURE
		
		if actor.current_state == actor.WORKING:
			return SUCCESS
	
	return FAILURE
