class_name Interactable extends Area3D

@export var trigger_dialog:bool
@export var dialog_key:String


func _init() -> void:
	input_event.connect(_on_input_event, CONNECT_REFERENCE_COUNTED)
	mouse_entered.connect(_on_mouseover.bind(true))
	mouse_exited.connect(_on_mouseover.bind(false))


func interact():
	if trigger_dialog:
		Global.dialog_triggered.emit(dialog_key)


func _on_input_event(_camera: Node, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_action_pressed("right_click"):
			Global._on_interactable_selected(self)


func _on_mouseover(mo:bool):
	if get_node_or_null("Label3D"):
		$Label3D.visible = mo


func _on_ready() -> void:
	if get_node_or_null("Label3D"):
		$Label3D.text = name
