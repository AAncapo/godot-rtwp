extends Node3D

const MOVE_MARGIN = 0 
const MOVE_SPEED = 30
@onready var cam = $Camera3D


func _ready():
	GameEvents.focus_worldobject.connect(on_worldobject_focused)


func _process(delta):
	var m_pos = get_viewport().get_mouse_position()
	calc_move(m_pos,delta)


func _unhandled_input(event):
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				cam.position.z -= 1
			MOUSE_BUTTON_WHEEL_DOWN:
				cam.position.z += 1


func calc_move(_m_pos, delta):
#	var v_size = get_viewport().size
	var move_vec = Vector3()
#	if m_pos.x < MOVE_MARGIN || 
	if Input.is_action_pressed("cam_left"):
		move_vec.x -= 1
#	if m_pos.y < MOVE_MARGIN || 	
	if Input.is_action_pressed("cam_fwd"):
		move_vec.z -= 1
#	if m_pos.x > v_size.x - MOVE_MARGIN || 
	if Input.is_action_pressed("cam_right"):
		move_vec.x += 1
#	if m_pos.y > v_size.y - MOVE_MARGIN || 
	if Input.is_action_pressed("cam_bwd"):
		move_vec.z += 1
	move_vec = move_vec.rotated(Vector3.UP, rotation_degrees.y)
	global_translate(move_vec * delta * MOVE_SPEED)


func on_worldobject_focused(obj, focus=true):
	if focus:
		global_transform.origin = obj.global_position
