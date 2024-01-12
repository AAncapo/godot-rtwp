class_name DetectionArea extends Area3D
## REMEMBER set collisionShape resource as local!!!

@onready var fov:RayCast3D = $FieldOfView
var radius:
	set(value):
		radius = value
		$CollisionShape3D.shape.radius = value


func is_inside_fov(target:Character):
	fov.look_at(target.global_position, Vector3.UP)
	fov.target_position = Vector3(0,0,-radius)
	
	var collide_w_target = fov.get_collider() == target
	return collide_w_target


func get_units_in_area(only_enemies:bool = true) -> Array:
	var units = get_overlapping_bodies()
	#exclude owner unit
	if units.find(owner) >= 0:
		units.remove_at(units.find(owner))
	
	if only_enemies:
		var enemies = []
		if units.size() > 0:
			for u in units:
				if owner.is_enemy(u):
					enemies.append(u)
		return enemies
	return units
