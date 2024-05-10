extends ConditionLeaf

enum CheckFor {
	POSITION_VECTOR,
	UNIT
}
@export var check_for = CheckFor.POSITION_VECTOR

func tick(actor,bb):
	if not actor.target or not actor.nav_agent.is_target_reachable():
		actor.nav_agent.target_position = Vector3()
		actor.animationTree.stop_motion()
		return FAILURE
	return SUCCESS
