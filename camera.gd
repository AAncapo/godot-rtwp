extends Node3D

var move_speed: float = .5
@export var zoom_speed: float = 3.0

@onready var cam = $Camera3D
@onready var new_pos:Vector3 = self.global_position
var mouse_sens = 0.004


func _process(_delta: float) -> void:
	#move with wasd
	if Input.is_action_pressed("cam_left"):
		new_pos -= global_basis.x
	if Input.is_action_pressed("cam_fwd"):
		new_pos -= global_basis.z
	if Input.is_action_pressed("cam_right"):
		new_pos += global_basis.x
	if Input.is_action_pressed("cam_bwd"):
		new_pos += global_basis.z
	
	global_position = new_pos
	
	if global_position.y <= 2: global_position.y = 2
	if global_position.y >= 15: global_position.y = 15
	

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:  #rotate holding middle mouse button
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			self.global_rotation.y -= event.relative.x * mouse_sens
			cam.rotation.x -= event.relative.y * mouse_sens
	
	if event is InputEventMouseButton && event.is_pressed(): #zoom with mouse wheel
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_pos -= cam.global_basis.z * zoom_speed
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_pos += cam.global_basis.z * zoom_speed
