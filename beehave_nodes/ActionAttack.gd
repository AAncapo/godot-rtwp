extends ActionLeaf


func tick(actor, blackboard):
	var enemy = actor.target_unit
	var is_ready = actor.time_left <= 0
	actor.rotate_to(enemy.global_position)
	
	if is_ready and enemy:
		#change anim to aiming
		actor.anim.aim(true)
	
		actor.attack(enemy)
		actor.action_timer.start()
		is_ready = false
		return SUCCESS
	return RUNNING
