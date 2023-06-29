extends Node3D

signal command_units(units,target_obj,dbl_clickd)

@export_node_path("Camera3D") var camera
@onready var cam = get_node(camera)
@onready var selection_box = $SelectionBox

const PLAYER_TEAM = 0
const RAY_LENGTH = 1000

var selected_units = []
var start_sel_pos = Vector2()

var target_unit: Unit


func _ready():
	GameEvents.focus_worldobject.connect(__on_unit_selected)
	GameEvents.character_died.connect(on_unit_died)

var dbl_clck_timer:float = 0
func _process(delta):
	if dbl_clck_timer > 0:
		dbl_clck_timer -= delta


func _unhandled_input(_event):
	var m_pos = get_viewport().get_mouse_position()
	
	var dbl_clck=false
	if Input.is_action_just_pressed("main_command"): #right click
		dbl_clck = dbl_clck_timer > 0
		dbl_clck_timer = 0.2
		command_selected_units(m_pos, dbl_clck)
	if Input.is_action_just_pressed("alt_command"):
		selection_box.start_sel_pos = m_pos
		start_sel_pos = m_pos
	if Input.is_action_pressed("alt_command"):
		selection_box.m_pos = m_pos
		selection_box.is_visible = true
	else:
		selection_box.is_visible = false
	if Input.is_action_just_released("alt_command"):
		deselect_all_units()
		select_units(m_pos)


func command_selected_units(m_pos:Vector2,dbl_clickd:bool):
	var result = raycast_from_mouse(m_pos, 1)
	if result:
		command_units.emit(selected_units, result, dbl_clickd)
		return result


func select_units(m_pos):
	var new_selected_units = []
	if m_pos.distance_squared_to(start_sel_pos) < 4:
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		new_selected_units = get_units_in_box(start_sel_pos, m_pos)
	if new_selected_units.size() != 0:
		deselect_all_units()
		for unit in new_selected_units:
			unit.emit_signal('selected')
		selected_units = new_selected_units


func deselect_all_units():
	for unit in selected_units:
		unit.emit_signal('deselected')
	selected_units.clear()
	
	if target_unit:
		target_unit.deselect_as_target.emit()


func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and result.collider.is_in_group('units'):
		## allow !player_team units if selected independent
		return result.collider


func get_units_in_box(top_left, bottom_right):
	if top_left.x > bottom_right.x:
		var tmp = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = tmp
	if top_left.y > bottom_right.y:
		var tmp = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = tmp
	var box = Rect2(top_left, bottom_right - top_left)
	var box_selected_units = []
	for unit in get_tree().get_nodes_in_group("units"):
		if box.has_point(cam.unproject_position(unit.global_transform.origin)) && unit.team == PLAYER_TEAM:
			## ignore !player_team units in box selection
			box_selected_units.append(unit)
	return box_selected_units


func raycast_from_mouse(m_pos, _collision_mask = null):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * RAY_LENGTH
	var space_state = cam.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(ray_start,ray_end)
	return space_state.intersect_ray(params)

## callback for selecting units using elements outside the SelectionSystem node tools (e.g. character portraits) ##
func __on_unit_selected(unit):
	if unit.is_in_group('units'):
		deselect_all_units()
		selected_units.append(unit)

func on_unit_died(unit):
	if selected_units.has(unit):
		selected_units.remove_at(selected_units.find(unit))
