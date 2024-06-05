extends ActionLeaf


func tick(actor, _blackboard):
	var target = actor.target_unit
	if target:
		if actor.crosshair.get_collider() == target:
			actor.selected_action.execute()
			actor.end_turn()
			return SUCCESS
	return FAILURE
