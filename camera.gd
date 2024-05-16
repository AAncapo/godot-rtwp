extends Node3D

@export var move_speed: float = 3.0
@export var zoom_speed: float = 3.0

@onready var cam = $Camera3D
@onready var new_pos:Vector3 = self.global_position
var mouse_sens = 0.004


func _ready() -> void:
	Global.focus_world_object.connect(_on_focus)

func _process(delta: float) -> void:
	#move with wasd
	if Input.is_action_pressed("cam_left"):
		new_pos -= global_basis.x
	if Input.is_action_pressed("cam_fwd"):
		new_pos -= global_basis.z
	if Input.is_action_pressed("cam_right"):
		new_pos += global_basis.x
	if Input.is_action_pressed("cam_bwd"):
		new_pos += global_basis.z
	
	global_position = lerp(global_position,new_pos, delta * move_speed)
	
	if global_position.y <= 2: global_position.y = 2

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


func _on_focus(object):
	pass
