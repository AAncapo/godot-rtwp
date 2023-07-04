extends State
class_name Combat

var wait_time:float

func enter():
	randomize()
	
	mov.move_speed = _char.walk_spd
	_char.safe_dist = _char.optimal_hr
	
	wait_time = 2.0


func update(delta:float):
	## search for enemies if target died and no new position is given
	if !target_char || target_char.is_dead:
		if target_pos != Vector3.ZERO:
			changed.emit('move')
			return
		var enemies_left = da.get_units_in_area(_char,true)
		if enemies_left.size() > 0:
			if _char.at_range_from(enemies_left[0]):
				_char.target = enemies_left[0]
				return
		changed.emit('idle')
		return
	
	# checking if can attack
	if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
		if wpn_ctrl.pointing_at_target(target_char):
			wpn_ctrl.attack(delta)
	elif !da.is_inside_fov(target_char):
		wait_time -= delta
		if wait_time < 0:
			changed.emit('alert')


func update_physics(delta:float):
	## rotation and movement while rungun is active ##
	if rungun: 
		# rotate towards current target if no new targetpos
		mov.rotate_to(target_char.position,delta)
		if target_pos == Vector3.ZERO:
			## move away from target if its too close ##
			var dist: float = (_char.global_position - target_char.global_position).length()
			if dist < _char.safe_dist - 0.5:
				## TODO: check if position is reachable for mov.agent ##
				var safe_pos: Vector3 = _char.global_position + (_char.transform.basis.z * 10.0)
				mov.move_to(safe_pos, false)
			else:
				mov.move_to(target_char.position, true)
		else:
			# if new targetpos
			# keep looking at target until is not inside hit_range or visible
			var rotate:bool
			if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
				rotate = false
			else:
				target_char = null
				rotate = true
				changed.emit('move')
			mov.move_to(target_pos, rotate)


func get_random_dir(start_pos:Vector3):
	var __range:float = randf_range(-1.0,1.0)
	var rdir:Vector3 = Vector3(__range,start_pos.y,__range)
	return (rdir-start_pos).normalized()
