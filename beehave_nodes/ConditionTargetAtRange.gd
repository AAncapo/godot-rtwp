extends ConditionLeaf


func tick(actor, _blackboard):
	if !actor.target_unit: return FAILURE
	
	var action = actor.selected_action
	var enemy = actor.target_unit
	var dist:Vector3 = (enemy.global_position - actor.global_position)
	#var max_desired_dist = action.range_ * .8
	#TODO: only take maxdesired if equipped wpn is ranged
	
	## Quite el check_visibility para limpiar un poco el script del chara.
	##TODO Hay que ajustar la manera en que determina la nueva posicion considerando habitaciones peque;as
	if dist.length() < action.range_ and actor.check_visibility(enemy):
		actor.target_vec = null
		actor.anim.aim(true)
		return SUCCESS
	
	actor.anim.aim(false)
	
	if !actor.target_vec:
		actor.target_vec = enemy.global_position
		#var new_pos:Vector3
		#new_pos = actor.global_position + (dist.normalized() * (dist.length() - max_desired_dist))
		#
		#actor.target_vec = new_pos
	
	return FAILURE
