extends Control

enum PROP { RotationY, RotationX, Zoom }

@onready var properties := $PanelContainer/VBoxContainer/properties
@export_node_path("Camera3D") var camera_path
@onready var camera = get_node_or_null(camera_path)


func init():
	for p in properties.get_children():
		var buttons_container = p.get_child(1) as HBoxContainer
		for b in buttons_container.get_children():
			if b.name == "sub": b.pressed.connect(_on_sub_pressed.bind(p.name))
			if b.name == "add": b.pressed.connect(_on_add_pressed.bind(p.name))
			if b.name == "value": b.text = get_value_from_key(p.name)


func get_value_from_key(key:String) -> float:
	var value:float
	return value


func _on_sub_pressed(property_name:String):
	pass

func _on_add_pressed(property_name:String):
	pass
