extends Node3D

@onready var fov:Area3D = $FieldOfView
@onready var da:Area3D = $DetectionArea
var unit

func update_fov():
	fov.get_node("CollisionShape3D").shape.size.z = unit.visibility_range
	fov.position.z = -unit.visibility_range/2


func get_enemies_in_area():
	var detected_units = []
	var bodies = da.get_overlapping_bodies()
	for b in bodies:
		if unit.is_enemy(b):
			detected_units.append(b)
	return detected_units

func get_closest_enemy_in_area():
	var closest_enemy
	var enemies = get_enemies_in_area()
	var pos = unit.global_position
	
	for e in enemies:
		if !closest_enemy: closest_enemy = e
		if (e.global_position - pos).length() < (closest_enemy.global_position - pos).length():
			closest_enemy = e
	
	return closest_enemy


func _on_detection_area_body_entered(body: Node3D) -> void:
	if unit.is_enemy(body): 
		if !unit.bt.enabled: unit.bt.enabled = true  #improve performance
		
		if body.current_state != body.STEALTH:
			if unit.current_state != unit.STEALTH: unit.current_state = unit.ALERT
			#or DOWNED (well maybe when in states like downed the detectionHandler should be disabled)
			if unit.team != Global.PLAYER_TEAM and not unit.target_unit:
				unit.target_unit = body
				unit.end_turn()
				#unit.target_unit.detected.emit()

func _on_detection_area_body_exited(body: Node3D) -> void:
	if unit.team == Global.PLAYER_TEAM:
		return
	
	if body == unit.target_unit:
		## If the current target exits the area search other enemies nearby
		unit.end_turn()
		var new_target = get_closest_enemy_in_area()
		unit.target_unit = null if !new_target else new_target
		## If no enemies around then follow the previous target last position
		if !unit.target_unit:
			unit.target_vec = body.global_position


func _on_field_of_view_body_entered(body: Node3D) -> void:
	if unit.is_enemy(body):
		## The Player units can't auto select enemies on detection
		if unit.team != Global.PLAYER_TEAM and not unit.target_unit:
			if not check_visibility(body) and body.current_state == body.STEALTH:
				#ignore if is not visible and using stealth
				return
			unit.target_unit = body
		if body.current_state == body.STEALTH: unit.target_unit.detected.emit()
		if unit.current_state != unit.STEALTH: unit.current_state = unit.ALERT


func check_visibility(target):
	var vcheck:RayCast3D = $VisibilityChecker
	vcheck.look_at(target.global_position)
	var len = (target.global_position - unit.global_position).length()
	vcheck.target_position.z = -len * 1.2
	vcheck.target_position.y = target.scale.y/2
	vcheck.force_raycast_update()  # doesnt need to be enabled for this to work
	return vcheck.get_collider() == target
