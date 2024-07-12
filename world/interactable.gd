class_name Interactable extends Area3D


func _init() -> void:
	input_event.connect(_on_input_event)


func interact():
	pass


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("right_click"):
			Global._on_interactable_selected(self)


func _on_mouseover(mo:bool):
	pass
