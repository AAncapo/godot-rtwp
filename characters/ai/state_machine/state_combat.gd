class_name Combat extends State

var wait_time:float
var relocating:bool = false
var newpos:Vector3:
	set(val):
		newpos = val
		character.mov.move_to(newpos, false) #move without rotating toward newpos
var cspot_shoot_pos:Vector3


func enter():
	super.enter()
	
	cspot_shoot_pos = Vector3()
	relocating = false
	randomize()
	wait_time = 3.0


func update(delta:float):
	if !target || target.dead: return
	
	if character.is_behind_cover && cspot_shoot_pos == Vector3.ZERO:
		cspot_shoot_pos = character.shootBehindCoverPos
	# checking if can attack
	if character.at_range_from(target) && character.da.is_inside_fov(target):
		#TODO: perform lean/stand animation
		if character.wpnCtr.pointing_at_target(target):
			character.attack()
	
	elif character.ai_enabled && !character.da.is_inside_fov(target):
		wait_time -= delta
		if wait_time < 0:
			character.curr_cspot = null
			changed.emit('search',target)


func update_physics(delta:float):
	#look/aim at target
	character.mov.rotate_to(target.position, delta)
	
	if !character.is_behind_cover: 
		if !character.ai_enabled: return
		#check and move away from target if its too close
		var currdist:float = character.global_position.distance_to(target.global_position)
		if currdist <= character.curr_safdist/2 && !relocating:
			relocating = true
			character.curr_safdist = 1  #set to base_safdist before calling move_to
			self.newpos = target.global_position + (character.transform.basis.z * (character.combat_safdist + 1))
			##TODO: check if newpos is reachable by agent.
			##TODO: change direction from basis.z to somewhere random behind the unit.
		if relocating && newpos != Vector3.ZERO && character.global_position.distance_to(newpos) < 0.1:
			newpos = Vector3()
			relocating = false
			character.curr_safdist = character.combat_safdist
		
		
#	#handle rungun in controller before set next state when target updated
#	#example: if target==vector3 and curr state = combat dont go directly to state move?
#
#	### THIS CODE NEVER RUNS now bc when target != vector3 its already in state.move
#		if target is Vector3:
#			# if new targetpos keep looking at target until is not inside hit_range or visible
#			var rotate:bool
#			if character.at_range_from(target) && character.da.is_inside_fov(target):
#				rotate = false
#			else:
#				target = null
#				rotate = true
#				changed.emit('move',target.position)
#
#		## avoid calling move_to inside process ##
#			character.mov.move_to(target, rotate)


#func get_random_dir(start_pos:Vector3):
#	var __range: float = randf_range(-1.0, 1.0)
#	var rdir: Vector3 = Vector3(__range, start_pos.y, __range)
#	return (rdir - start_pos).normalized()
