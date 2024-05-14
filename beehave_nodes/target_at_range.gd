extends ConditionLeaf

var fixed_pos:Vector3


func tick(actor, blackboard):
	var min_desired_dist:float = actor.melee_range * 2.0
	var max_desired_dist:float = actor.hit_range * .8
	var dist:Vector3 = (actor.target_unit.global_position - actor.global_position)
	var is_using_melee = not actor.equipped_weapon or actor.equipped_weapon.item_class == "melee"
	
	if dist.length() < actor.hit_range:
		#(!) Do NOT check min_desired_dist if using melee or unarmed
		if !is_using_melee:
			if dist.length() > min_desired_dist:
				fixed_pos = Vector3()
				actor.target_vec = null
				return SUCCESS
		else:
			fixed_pos = Vector3()
			actor.target_vec = null
			return SUCCESS
	else:
		#set agent position to a vector close enough to hit
		if not fixed_pos.length() and actor.target_unit:
			print(actor.name, " init fixed pos")
			if dist.length() < min_desired_dist and !is_using_melee:  #is too close -> move back
				#TODO: equip enemy with a ranged weapon to test this section
				print(actor.name," target is too close. new pos between min&max desired dst")
				dist = actor.global_position - actor.target_unit.global_position
				fixed_pos = actor.global_position + (dist.normalized() * (randi_range(min_desired_dist, max_desired_dist)))
			else:  #is too far -> move forward
				print(actor.name," target is too far. new pos somewhere near max desired dst")
				fixed_pos = actor.global_position + (dist.normalized() * (dist.length() - max_desired_dist))
			actor.target_vec = fixed_pos
	
	#if fixed_pos reached but target not at range ...
	if fixed_pos.length() and actor.nav.is_target_reached():
		print(actor.name," fixed pos reached but target not found")
		fixed_pos = Vector3()
		#search other enemies if the target escapes
		if dist.length() > actor.hit_range or dist.length() > max_desired_dist:
			print(actor.name, " searching enemies left")
			var enemies = actor.get_enemies_in_area(actor.detection_area)
			actor.target_unit = enemies[0] if enemies else null
			if not actor.target_unit: actor.current_state = actor.state.NORMAL
	
	return FAILURE
