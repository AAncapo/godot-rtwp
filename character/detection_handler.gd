extends Node3D

@onready var fov = $fov
var actor:Character
var fov_enabled:bool = false
var detect_motion:float = .5
var enemies_in_area = []


func _ready() -> void:
	await get_parent().ready
	actor = get_parent()
	gen_fov(actor.stats.visibility_range * .8)
	enable_fov(false)


func _physics_process(delta: float) -> void:
	if fov_enabled and !actor.is_player():
		var collider = get_fov_collider()
		if collider and collider != actor.target_unit:
			collider.detected.emit()
			if !actor.target_unit: actor.target_unit = collider
			
			# Calling allies in the area
			#TODO change this to only alert ally units in connected rooms
			var allies = get_units_in_area(0)
			for a in allies:
				if a.current_state != Character.State.ALERT and !a.target_unit:
					a.current_state = Character.State.ALERT
					a.target_vec = collider.global_position
	
	#TODO: only start counter when detects movement
	if !actor.is_player() and enemies_in_area and !actor.target_unit:
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
	#Note: 
	#If a unit is moving to attack a target that is too far away or in a position which requires to follow a path that makes the target exit the player's DetectionArea at some point, the player will stop moving immediatelly(State.IDLE). This happens because when this method is called, if the exited body is the target_unit's, the unit interprets it as: 'target has escaped' and its not programmed to chase after it, so it stops. This shouldnt be common when the rooms are obscured (as intended) bc you will not be able to target enemies that far away, so im not going to bother 'fixing' it.
	if actor.is_enemy(body):
		if enemies_in_area.has(body): enemies_in_area.remove_at(enemies_in_area.find(body))
		# disable fov when no more enmies around
		var new_target = get_closest_unit_in_area(1)
		if !new_target: 
			enable_fov(false)
			actor.current_state = Character.State.IDLE
		
		# If the current target exited the area search other enemies nearby
		if body == actor.target_unit:
			actor.target_unit = null
			actor.end_turn()
			#TODO: check new target visibility (???)
			#(?) sort the detected_enemies array prioritizing visible targets over close ones
			actor.target_vec = null if !new_target else new_target.global_position
			
			if !actor.is_player():
				#Move to the previous target last position if no enemies around then 
				if !actor.target_vec: actor.target_vec = body.global_position


func handle_detected_body(body):
	if !body.stealth_on:
		#Check if target is in the same or a connected room
		var curr_room = actor.bound_area.get_current_room()
		var target_room = body.bound_area.get_current_room()
		if curr_room and target_room:
			if !curr_room.is_room_equal_or_connected(target_room):
				return
		
		#PLAYER: if not in stealth set to alert
		if actor.is_player() and !actor.stealth_on: 
			actor.current_state = Character.State.ALERT
			if not actor.selected_action:
				#TODO make action_move (NOPE)
				actor.target_unit = body
		
		#ENEMY: if dont have a target already set body as target
		if !actor.is_player() and !actor.target_unit:
			actor.target_unit = body
			actor.current_state = Character.State.ALERT
			
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
			0: value = !actor.is_enemy(b)
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
