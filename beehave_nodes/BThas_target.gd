extends ConditionLeaf

func tick(actor, blackboard):
	if actor.target_vec or actor.target_unit:
		return SUCCESS
	return FAILURE
