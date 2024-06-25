extends Node3D
@onready var navlink :NavigationLink3D = $NavigationLink3D
@onready var anim :AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	navlink.enabled = false #apparently needs to be enabled on when NavigationRegion loads so it can be taken into account


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		open()


func open():
	anim.play("open")
	await  anim.animation_finished
	navlink.enabled = true
