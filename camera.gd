extends Node3D

@export var zoom_speed:float = 3.0
@onready var cam := $CamPivot/Camera3D
@onready var new_pos:Vector3 = self.global_position
var mouse_sens = 0.004
var move_speed:float = .5


func _ready() -> void:
	Global.unit_focused.connect(focus_camera_on)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("cam_left"):
		new_pos -= global_basis.x
	if Input.is_action_pressed("cam_fwd"):
		new_pos -= global_basis.z
	if Input.is_action_pressed("cam_right"):
		new_pos += global_basis.x
	if Input.is_action_pressed("cam_bwd"):
		new_pos += global_basis.z
	
	global_position = new_pos


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:  #rotate holding middle mouse button
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			self.global_rotation.y -= event.relative.x * mouse_sens
	
	if event is InputEventMouseButton && event.is_pressed(): #zoom with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_pos -= cam.global_basis.z * zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_pos += cam.global_basis.z * zoom_speed


func focus_camera_on(pos:Vector3):
	new_pos = pos
