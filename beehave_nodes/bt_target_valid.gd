extends ConditionLeaf

@export var desired_class:String

func tick(actor,blackboard):
	if desired_class == "vector" and actor.target_vec: return SUCCESS
	if desired_class == "enemy" and actor.target_unit: return SUCCESS
	return FAILURE
