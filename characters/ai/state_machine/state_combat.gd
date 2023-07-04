extends State
class_name Combat

var wait_time:float

func enter():
	mov.move_speed = _char.alert_spd
	_char.safe_dist = _char.optimal_hr
	
	wait_time = 2.0


func update(delta:float):
	if !target_char || target_char.is_dead:
		if target_pos != Vector3.ZERO:
			changed.emit('move')
			return
		# search for enemies if target died and no new position is given
		var enemies_left = da.get_units_in_area(_char,true)
		if enemies_left.size() > 0:
			if _char.at_range_from(enemies_left[0]):
				_char.target = enemies_left[0]
				return
		changed.emit('idle')
		return
	
	# checking if can attack
	if _char.at_range_from(target_char):
		if da.is_inside_fov(target_char):
			if wpn_ctrl.pointing_at_target(target_char):
				wpn_ctrl.attack(delta)
		else:
			changed.emit('follow')
	else:
		if wait_time < 0:
			changed.emit('alert')


func update_physics(delta:float):
	var tchar_pos = target_char.position
	
	## rotation and movement while rungun is active ##
	if rungun: 
		# rotate towards current target if no new targetpos
		# chase current target if escapes hit_range
		if target_pos==Vector3.ZERO:
			mov.rotate_to(tchar_pos,delta)
			if !_char.at_range_from(target_char):
				wait_time -= delta
				if wait_time < 0:
					wait_time = 1.0
					mov.move_to(tchar_pos)
		else:
			# if new targetpos
			# keep looking at target until is not inside hit_range or visible
			var rotate:bool
			if _char.at_range_from(target_char) && da.is_inside_fov(target_char):
				rotate = false
			else:
				rotate = true
				changed.emit('move')
			mov.move_to(target_pos, rotate)
