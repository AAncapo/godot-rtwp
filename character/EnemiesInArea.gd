extends ConditionLeaf

func tick(actor, blackboard):
	print(actor.name, " searching enemies in area")
	var pos = actor.global_position
	
	var enemies = actor.detectionHandler.get_enemies_in_area()
	if enemies:
		var new_target
		for e in enemies:
			if !new_target: new_target = e
			if (e.global_position - pos).length() < (new_target.global_position - pos).length():
				new_target = e
		
		print(actor.name, " found new enemy")
		actor.target_unit = new_target
		return SUCCESS
	print(actor.name, " couldnt find more enemies")
	actor.target_unit = null
	return FAILURE
