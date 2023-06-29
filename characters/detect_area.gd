extends Area3D
class_name DetectionArea
## REMEMBER set collisionShape resource as local!!!

@onready var fov:RayCast3D = $FieldOfView


var radius:
	set(value):
		radius = value
		$CollisionShape3D.shape.radius = value


func is_inside_fov(target:Character):
	fov.look_at(target.global_position, Vector3.UP)
	fov.target_position = Vector3(0,0.5,-radius)
	
	var collide_w_target = fov.get_collider() == target
	return collide_w_target


func get_units_in_area(exclude:Character, only_enemies:bool = true) -> Array:
	var units = get_overlapping_bodies()
	#exclude this(self) unit
	if units.find(exclude) >= 0:
		units.remove_at(units.find(exclude))
	
	if only_enemies:
		var enemies = []
		if units.size() > 0:
			for u in units:
				if exclude.is_enemy(u):
					enemies.append(u)
		return enemies
	return units
