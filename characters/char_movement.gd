class_name CharacterMovement extends Node

@onready var agent = %NavigationAgent3D
var _char:Character
var move_speed:float
var rotate: bool = true


func _physics_process(delta: float) -> void:
	var dir = Vector3()
	if agent.target_position && !agent.is_target_reached():
		dir = (agent.get_next_path_position() - _char.global_position).normalized()
		_char.velocity = _char.velocity.lerp(dir * move_speed, 10 * delta)
		
		if rotate:
			rotate_to(agent.get_next_path_position(), delta)
		_char.move_and_slide()


func is_target_reached():
	return agent.is_target_reached()


func move_to(target_pos:Vector3, _rotate:bool = true) -> void:
	self.rotate = _rotate
	target_pos.y = 0  #evitar bug donde el target esta encima del suelo(y>0) y el agent trata de llegar
	
	agent.target_position = target_pos
	if !agent.is_target_reachable():
		agent.target_position = _char.global_position
		print("Target isn't reachable!")
		return
	
	%GUI.set_location_indicator(target_pos)


func rotate_to(target:Vector3, delta:float):
	if _char.global_transform.origin.is_equal_approx(target):
		return
	var new_transform = _char.transform.looking_at(target, Vector3.UP)
	_char.transform = _char.transform.interpolate_with(new_transform, _char.rot_sp * delta)


func _on_navigation_agent_3d_target_reached():
	_char.velocity = Vector3.ZERO
