extends ConditionLeaf

func tick(actor, blackboard):
	if actor.is_turn:
		#print("is ", actor.name ," turn")
		return SUCCESS
	return FAILURE
