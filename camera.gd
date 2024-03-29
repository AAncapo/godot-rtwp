extends Node3D

@export_range(5.0,30.0) var move_speed: float = 10.0
@export var zoom_amount: float = 10.0
@export var min_zoom: float = 5.0
@export var max_zoom: float = 50.0

@onready var cam = $Camera3D
@onready var new_pos: Vector3 = self.global_position
@onready var new_zoom: float = cam.position.z
@onready var new_rotation_y: float = self.global_rotation.y

var mouse_sensitivity: float = 0.05
var rotation_speed: float = 0.2
var isset_tactical:bool = false

var cam_settings = {
	'projection': [0, 1],
	'size': [1, 50],
	'parent/global_rotation_degrees/x': [-60, -90]
	}


func _ready() -> void:
#	set_tactical_mode(true)
	GameEvents.focus_world_object.connect(on_world_object_focused)


func _process(delta: float) -> void:
	calc_move(delta)
	
	if Input.is_action_just_pressed("tactical_mode"):
		set_tactical_mode(!isset_tactical)


func _unhandled_input(event: InputEvent) -> void:
	## Zoom camera w mouse wheel ##
	if event is InputEventMouseButton && event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			new_zoom -= zoom_amount
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			new_zoom += zoom_amount
		new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	
	
	if event is InputEventMouseMotion:
#		## Pan camera w middle mouse button ##
		if event.button_mask == MOUSE_BUTTON_MASK_MIDDLE:
			new_pos -= Vector3(event.relative.x * mouse_sensitivity,0,event.relative.y * mouse_sensitivity)
		
#		if event.button_mask == MOUSE_BUTTON_RIGHT:
#			new_rotation_y = deg_to_rad(event.relative.x) * rotation_speed
#			self.global_rotate(Vector3.UP, new_rotation_y)


func calc_move(delta:float) -> void:
	## Move camera using WASD/arrow keys ##
	if Input.is_action_pressed("cam_left"):
		new_pos += Vector3.LEFT
	if Input.is_action_pressed("cam_fwd"):
		new_pos += Vector3.FORWARD
	if Input.is_action_pressed("cam_right"):
		new_pos += Vector3.RIGHT
	if Input.is_action_pressed("cam_bwd"):
		new_pos += Vector3.BACK
	
	global_position = lerp(global_position,new_pos, delta * move_speed)
	cam.position.z = lerp(cam.position.z, new_zoom, delta * move_speed)


func set_tactical_mode(tactical:bool):
	var index = 0 if !tactical else 1
	for prop in cam_settings.keys():
		cam.set(prop, cam_settings[prop][index])
	isset_tactical = tactical

 
func on_world_object_focused(obj, focus=true):
	if focus:
		new_pos = obj.global_position
