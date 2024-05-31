extends ActionLeaf


func tick(actor, blackboard):
	var target = actor.target_unit
	if target:
		if actor.crosshair.get_collider() == target:
			actor.execute_action()
			actor.end_turn()
			return SUCCESS
	return FAILURE
