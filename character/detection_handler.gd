extends Node3D

@onready var fov = $fov
var actor
var fov_enabled:bool = false
var detect_motion:float = .5
var enemies_in_area = []


func _ready() -> void:
	await get_parent().ready
	actor = get_parent()
	gen_fov(actor.visibility_range * .8)
	enable_fov(false)


func _physics_process(delta: float) -> void:
	if fov_enabled and actor.team != Global.PLAYER_TEAM:
		var collider = get_fov_collider()
		if collider and collider != actor.target_unit:
			collider.detected.emit(actor)
			if !actor.target_unit: actor.target_unit = collider
			
			# Calling allies in the area
			var allies = get_units_in_area(0)
			for a in allies:
				if a.current_state != Character.ALERT and !a.target_unit:
					a.current_state = Character.ALERT
					a.target_vec = collider.global_position
	
	#TODO: only start counter when detects movement
	if enemies_in_area and !actor.target_unit:
		detect_motion -= delta
		if detect_motion < 0:
			for e in enemies_in_area:
				if e.is_moving:
					handle_detected_body(e)
			detect_motion = .5


func _on_detection_area_body_entered(body: Node3D) -> void:
	if actor.is_enemy(body):
		if !enemies_in_area.has(body): enemies_in_area.append(body)
		enable_fov(true)
		handle_detected_body(body)


func _on_detection_area_body_exited(body: Node3D) -> void:
	if actor.is_enemy(body):
		if enemies_in_area.has(body): enemies_in_area.remove_at(enemies_in_area.find(body))
		# disable fov if no more enmies around
		var new_target = get_closest_unit_in_area(1)
		if !new_target: enable_fov(false)
		
		if actor.team == Global.PLAYER_TEAM: return
		
		# If the current target exited the area search other enemies nearby
		if body == actor.target_unit:
			actor.target_unit = null
			actor.end_turn()
			#TODO: check new target visibility (???)
			#(?) sort the detected_enemies array prioritizing visible targets over close ones
			actor.target_vec = null if !new_target else new_target.global_position
			
			#Move to the previous target last position if no enemies around then 
			if !actor.target_vec: actor.target_vec = body.global_position


func handle_detected_body(body):
	if body.current_state != body.STEALTH:
		#if this is player and not in stealth set to alert
		if actor.team == Global.PLAYER_TEAM and actor.current_state != actor.STEALTH: 
			actor.current_state = actor.ALERT
		#or DOWNED (in states like downed the detectionHandler should be disabled)
		
		#if this is ENEMy and dont have a target already set body as target
		if actor.team != Global.PLAYER_TEAM and not actor.target_unit:
			actor.target_unit = body
			actor.current_state = actor.ALERT
			
			actor.end_turn()


func enable_fov(enable:bool):
	for r in fov.get_children():
		r.enabled = enable
		if enable: r.force_raycast_update()
	fov_enabled = enable


func get_fov_collider():
	for r in fov.get_children():
		if r.is_colliding and r.get_collider(): 
			if r.get_collider().is_in_group(Global.UNIT_GROUP):
				var collider = r.get_collider()
				if collider.team != actor.team:
					return collider


func gen_fov(range_:float):
	var angle = 45.0
	while angle > -45.0:
		%fovRay.target_position.z = -range_
		var new_ray = %fovRay.duplicate()
		fov.add_child(new_ray)
		angle -= 5.0
		new_ray.rotation_degrees.y = angle


func get_units_in_area(unit_team:int = 0):
	var detected_units = []
	var bodies = %DetectionArea.get_overlapping_bodies()
	for b in bodies:
		var value:bool
		match unit_team:
			0: value = actor.is_ally(b)
			1: value = actor.is_enemy(b)
		
		if value: detected_units.append(b)
	return detected_units


func get_closest_unit_in_area(unit_team:int = 0):
	var closest_enemy
	var enemies = get_units_in_area(unit_team)
	var pos = actor.global_position
	
	for e in enemies:
		if !closest_enemy: closest_enemy = e
		if (e.global_position - pos).length() < (closest_enemy.global_position - pos).length():
			closest_enemy = e
	
	return closest_enemy
