extends ConditionLeaf


func tick(actor, _blackboard):
	if !actor.target_unit or !actor.selected_action: return FAILURE
	if actor.selected_action.target_self: return FAILURE
	
	var action = actor.selected_action
	var enemy = actor.target_unit
	var dist:Vector3 = (enemy.global_position - actor.global_position)
	
	##TODO Hay que ajustar la manera en que determina la nueva posicion considerando habitaciones peque;as
	#TODO if attacked by melee, change to melee / runaway
	if dist.length() < action.range_ and actor.check_visibility(enemy):
		actor.target_vec = null
		actor.anim.aim(true)
		return SUCCESS
	
	actor.anim.aim(false)
	
	if !actor.target_vec:
		actor.target_vec = enemy.global_position
	
	return FAILURE
