extends ActionLeaf

func tick(actor, _blackboard):
	#print(actor.name," is working")
	match actor.assignment:
		actor.Assignment.FOLLOW:
			if !actor.target_vec and Global.player_leader:
				var leader_pos = Global.player_leader.global_position
				if actor.global_position.distance_to(leader_pos) > 3.0:
					actor.target_vec = leader_pos
		actor.Assignment.PATROL:
			#Patrol slander
			if !actor.target_vec:
				#print("go to new point")
				actor.target_vec = actor.current_job.get_next_pos()
			return SUCCESS
