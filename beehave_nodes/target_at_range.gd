extends ConditionLeaf

#safe_hitrange: smaller hr to avoid stutter while enemy enter/exit the base hit_range repeatedly

var fixed_pos:Vector3


func tick(actor, blackboard):
	var safe_hitrange:float = actor.hit_range * .8  
	var target_unit = actor.target.collider
	var dist:Vector3 = (target_unit.global_position - actor.global_position)
	
	if (dist.length() < actor.hit_range or dist.length() <= safe_hitrange):
		if fixed_pos.length() > 0: fixed_pos = Vector3()
		return SUCCESS
	
	#set agent position to a vector close enough to hit
	if not fixed_pos.length():
		fixed_pos = actor.global_position + (dist.normalized() * (dist.length() - safe_hitrange))
		actor.nav_agent.target_position = fixed_pos
		print("updating new pos")
	
	#if agent.target_pos set and is not fixed_pos = is a player command -> remove target
	#if actor.nav_agent.target_position.length() > 0 and fixed_pos.length() <= 0:
		#actor.target = null
	
	return FAILURE
