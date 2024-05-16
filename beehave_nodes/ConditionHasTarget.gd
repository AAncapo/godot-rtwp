extends ConditionLeaf

@export var vector:bool
@export var enemy:bool

func tick(actor, blackboard):
	if vector and actor.target_vec: return SUCCESS
	if enemy and actor.target_unit: return SUCCESS
	return FAILURE
