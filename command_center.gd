extends Node

@onready var formation := $FormationGrid
@onready var rays := formation.get_node("rays").get_children()
@onready var points := formation.get_node("markers").get_children()


func _ready() -> void:
	init_formation()


func init_formation():
	for r:RayCast3D in rays:
		var point :Marker3D = points[r.get_index()]
		r.target_position = point.global_position - r.global_position


func get_valid_points() -> Array:
	var valid_points := []
	for r:RayCast3D in rays:
		if !r.is_colliding() or r.is_colliding() and r.get_collider().is_in_group("floor"):
			var point_vec = points[r.get_index()].global_position
			valid_points.append(point_vec)
	return valid_points


func _on_unit_selector_new_target(result: Dictionary) -> void:
	var grid_pos:Vector3 = result.position
	var _collider:CollisionObject3D = result.collider
	
	if result.normal.y == 0:
		grid_pos = grid_pos + result.normal
		grid_pos.y = 0
	formation.global_position = grid_pos
	
	await  get_tree().physics_frame
	
	
	var points :Array = get_valid_points()
	#points.reverse()
	for u in Global.selected_units:
		var pos:Vector3
		while !points.is_empty() and pos == Vector3.ZERO:
			u.nav.target_position = points.pop_front()
			if u.nav.is_target_reachable():
				pos = u.nav.target_position
				u.target_vec = pos

		if _collider.is_in_group(Global.UNIT_GROUP):
			if _collider.team != Global.PLAYER_TEAM:
				u.target_unit = _collider
