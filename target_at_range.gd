extends ConditionLeaf

@export var hit_range : float

func tick(actor, blackboard):
	if actor.target.collider.is_in_group("units") and actor.target.collider.team != 0:
		var target_unit = actor.target.collider
		if (target_unit.global_position - actor.global_position).length() < hit_range:
			return SUCCESS
	return FAILURE
