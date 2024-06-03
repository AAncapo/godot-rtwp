extends ConditionLeaf

func tick(actor, _blackboard):
	if actor.is_turn and !actor.stats.is_dead and actor.current_state != Character.DOWNED:
		return SUCCESS
	return FAILURE
