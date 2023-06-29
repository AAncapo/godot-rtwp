extends CharacterBody3D
class_name Bullet

var __owner
var speed: float
var max_dist:float
var starting_pos: Vector3


func _ready():
	starting_pos = global_position


func _physics_process(delta):
	if (starting_pos - global_position).length() < max_dist:
		#move forward
		var hit: KinematicCollision3D = move_and_collide(-transform.basis.z * speed * delta)
		if hit:
			var obj = hit.get_collider()
			if obj && obj.has_method('take_damage'):
				obj.take_damage(__owner, 1)
			queue_free()
	else:
		queue_free()


func init(_owner:Character, spd:float, _max_dist:float):
	__owner = _owner
	speed = spd
	max_dist = _max_dist
	
