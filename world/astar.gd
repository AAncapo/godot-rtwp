extends Node3D

const HEIGHT := 0.0
const STEP := 1.0
var points := {}
var astar := AStar3D.new()


func _ready() -> void:
	var floors := get_tree().get_nodes_in_group("floor")
	_add_points(floors)


func _add_points(floors:Array):
	for f:MeshInstance3D in floors:
		var aabb:AABB = f.get_aabb()
		var start_point = aabb.position
		var x_steps = aabb.size.x / STEP
		var z_steps = aabb.size.z / STEP
		
		for x in x_steps:
			for z in z_steps:
				var next_point = start_point + Vector3(x * STEP, 0, z * STEP)
				_add_point(next_point)


func _add_point(point:Vector3):
	point.y = HEIGHT
	
	var id = astar.get_available_point_id()
	astar.add_point(id,point)
	points[world_to_astar(point)] = id


func _connect_points():
	for p:String in points:
		var pos_str = p.split(",")
		var world_pos = Vector3(float(pos_str[0]), float(pos_str[1]), float(pos_str[2]))
		var coords = [-STEP,0,STEP]
		for x in coords:
			for z in coords:
				var offset = Vector3(x,0,z)
				
				if offset == Vector3.ZERO:
					continue
				
				var neighbor = world_to_astar(world_pos + offset)
				if points.has(neighbor):
					var current_id = points[p]
					var neighbor_id = points[neighbor]
					if !astar.are_points_connected(current_id, neighbor_id):
						astar.connect_points(current_id, neighbor_id)


func find_path(from:Vector3, to:Vector3) -> Array:
	var start_id = astar.get_closest_point(from)
	var end_id = astar.get_closest_point(to)
	return astar.get_point_path(start_id, end_id)


func world_to_astar(world:Vector3) -> String:
	var x = snapped(world.x, STEP)
	var y = snapped(world.y, STEP)
	var z = snapped(world.z, STEP)
	return "%d,%d,%d" % [x,y,z]
