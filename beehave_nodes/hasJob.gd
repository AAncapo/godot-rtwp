extends ConditionLeaf


func tick(actor, _blackboard):
	#if actor.is_player() and actor.assignment == Character.Assignment.NONE:
		#return FAILURE
	
	#if has assignment but no current job
	if actor.assignment != 0 and !actor.current_job:
		find_job(actor)
	
	if actor.current_job and actor.current_state != Character.State.ALERT:
		if actor.current_state != Character.State.WORKING:
			actor.current_state = Character.State.WORKING
			actor.target_vec = actor.current_job.get_last_pos()
			return FAILURE
		
		if actor.current_state == Character.State.WORKING:
			return SUCCESS
	
	return FAILURE


func find_job(actor:Character):
	match actor.assignment:
		Character.Assignment.NONE:
			#remain idle
			pass
		Character.Assignment.FOLLOW:
			actor.current_job = Job.new()
		Character.Assignment.PATROL:
			#search patrol paths in scene
			var patrol_paths = get_tree().get_nodes_in_group("patrol_path")
			#if not occupied, occupy by actor and send to it
			for pp in patrol_paths:
				if !pp.is_in_group("occupied"):
					pp.add_to_group("occupied")
					actor.current_job = Job.new(pp.get_children())
					#print(self.name, " has patrol job at ",pp.name)
					return
			actor.assignment = Character.Assignment.NONE  #no patrol path found
