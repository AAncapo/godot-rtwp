extends ConditionLeaf

func tick(actor, blackboard):
	if actor.is_turn:
		return SUCCESS
	return FAILURE
