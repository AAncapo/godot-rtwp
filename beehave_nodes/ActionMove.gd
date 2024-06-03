extends ActionLeaf

func tick(actor, _blackboard):
	if actor.target_vec:
		if !actor.target_unit:
			return SUCCESS  #so it doesnt run the combat logic
	return FAILURE
