extends ActionLeaf

func tick(actor, _blackboard):
	print(actor.name," is working")
	
	#Patrol slander
	if !actor.target_vec:
		print("go to new point")
		actor.target_vec = actor.job.get_next_pos()
	return SUCCESS
