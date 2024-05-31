extends ConditionLeaf

func tick(actor, blackboard):
	if actor.is_turn and !actor.stats.is_dead:
		return SUCCESS
	return FAILURE
