extends ConditionLeaf

enum CheckFor { ANY, POSITION_VECTOR, UNIT }
@export var check_for = CheckFor.ANY

func tick(actor,bb):
	var is_enemy = actor.target and actor.target.collider.is_in_group("units") and actor.target.collider.team != actor.team
	
	match check_for:
		0: if actor.target: return SUCCESS
		1: 
			if not is_enemy: actor.anim.hold()
			if actor.nav_agent.is_target_reached():
				actor.anim.stop()
				return FAILURE
			if actor.nav_agent.is_target_reachable() and actor.nav_agent.target_position != Vector3(0,0,0): return SUCCESS
		2: if is_enemy: return SUCCESS
	
	return FAILURE
