extends Node
class_name CharacterMovement

@onready var agent: NavigationAgent3D = %NavigationAgent3D
var _char: Character
var stopping_dist: float = 0.2
var move_speed: float  ## by default is set to run_speed
var rotate: bool = true

func _physics_process(delta: float) -> void:
	var dir = Vector3()
	if agent.distance_to_target() > stopping_dist:
		dir = (agent.get_next_path_position() - _char.global_position).normalized()
		_char.velocity = _char.velocity.lerp(dir * move_speed, 10 * delta)
		
		if rotate:
			rotate_to(agent.get_next_path_position(), delta)
		
		_char.move_and_slide()


func move_to(target_pos: Vector3, rotate:bool = true) -> void:
	stopping_dist = _char.safe_dist
	self.rotate = rotate
	agent.target_position = target_pos


func rotate_to(target:Vector3, delta:float):
	if _char.global_transform.origin.is_equal_approx(target):
		return
	var new_transform = _char.transform.looking_at(target, Vector3.UP)
	_char.transform = _char.transform.interpolate_with(new_transform, _char.rot_spd * delta)
