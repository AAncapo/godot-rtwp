class_name Cover extends State

var curr_cspot:
	set(value):
		curr_cspot=value
		character.curr_cspot = curr_cspot
		if curr_cspot: get_cover(curr_cspot)


func enter():
	super.enter()
	
	if character.ai_enabled: search_cover()  #if enabled, target must be an enemy
	#if disabled the cspot must be set manually 


func update_physics(_delta:float):
	if !curr_cspot: return
	
	if character.mov.is_target_reached():
		character.is_behind_cover = true
		print(character.name,' is_behind_cover.')
		#when the unit is set to cover manually i cant assume what needs to do next.
		if !character.ai_enabled:
			changed.emit('idle')
			return
		#when the ai gets behind cover ill be always bc has detected a new enemy.
		changed.emit('combat',target)
		
		#in combat state check if is_behind_cover AND target is at range/fov -> attack, if NOT at range/fov -> back to cover
		#TODO: implement checking if cover gives opportunity to shoot against target too


func search_cover():
	##TODO: this must be ONLY cspots inside a predefined area representing this unit's perception 
	var all_cspots = get_tree().get_nodes_in_group("cover")  
	#default to COMBAT if no cspot found
	if !all_cspots:
		changed.emit('combat', target)
		return
	
	var found_cspots = []
	for cs in all_cspots:
		if cs.is_effective_cover(target) && !cs.is_occupied:
			found_cspots.append(cs)
	
	#sort by distance
	if !found_cspots:
		changed.emit('combat', target)
		return
	var closest_cs:CoverSpot = found_cspots[0]
	for fcs in found_cspots:
		if (fcs.global_position.distance_to(character.global_position) 
		< closest_cs.global_position.distance_to(character.global_position)):
			closest_cs = fcs
		else: continue
	
	self.curr_cspot = closest_cs
	
	#TODO: the dist between target-cspot must be > than dist between self-cspot


func get_cover(cspot):
	character.mov.move_to(curr_cspot.global_position)
	print(character.name, " found cover! Moving..")
