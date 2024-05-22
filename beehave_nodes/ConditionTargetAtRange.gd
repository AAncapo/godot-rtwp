extends ConditionLeaf


func tick(actor, blackboard):
	if !actor.target_unit: return FAILURE
	
	var action = actor.selected_action
	var enemy = actor.target_unit
	var dist:Vector3 = (enemy.global_position - actor.global_position)
	var is_veible = actor.detectionHandler.check_visibility(enemy)
	var max_desired_dist = action.range_ * .8
	#TODO: only take maxdesired if equipped wpn is ranged
	
	if dist.length() < action.range_ and is_veible:
		actor.target_vec = null
		return SUCCESS
	
	if !actor.target_vec:
		var new_pos:Vector3
		if is_veible: ## If is visible get closer (move forward)
			new_pos = actor.global_position + (dist.normalized() * (dist.length() - max_desired_dist))
		else: ## If not visible search for him (move to his position)
			new_pos = enemy.global_position
		
		actor.target_vec = new_pos
	
	return FAILURE
