extends Node

signal command_units(units,target_obj)

@onready var cam = %Camera3D
@onready var selection_box = $SelectionBox  #Only handles the selection box's rendering

const PLAYER_TEAM = 0
const RAY_LENGTH = 1000

var selected_units = []
var target_unit: Unit


func _ready():
	GameEvents.focus_world_object.connect(__on_unit_selected)
	GameEvents.character_died.connect(on_unit_died)


func _unhandled_input(ev):
	if ev is InputEventMouseButton:
		var m_pos = get_viewport().get_mouse_position()
		if ev.is_action_pressed("right_click"):
			command_selected_units(m_pos)
		if ev.is_action_released("left_click"):
			deselect_all_units()
			select_units(m_pos)


func command_selected_units(m_pos:Vector2):
	var res = raycast_from_mouse(m_pos, 1)
	if res: GameEvents.command.emit(res)


func select_units(m_pos):
	var new_selected_units = []
	var box = selection_box.get_generated_box()
	if !box: #if single click the box will not me big enough to work
		var u = get_unit_under_mouse(m_pos)
		if u != null:
			new_selected_units.append(u)
	else:
		var box_selected_units = []
		for unit in get_tree().get_nodes_in_group("units"):
			if box.has_point(cam.unproject_position(unit.global_transform.origin)):
				new_selected_units.append(unit)
	
	if new_selected_units.size() != 0:
		deselect_all_units()
		for unit in new_selected_units:
			unit.selected.emit()
		selected_units = new_selected_units


func deselect_all_units():
	for unit in selected_units:
		unit.deselected.emit()
	selected_units.clear()
	
	if target_unit:
		target_unit.deselect_as_target.emit()


func get_unit_under_mouse(m_pos):
	var result = raycast_from_mouse(m_pos, 3)
	if result and result.collider.is_in_group("units"):
		return result.collider


func raycast_from_mouse(m_pos, _collision_mask = null):
	var ray_start = cam.project_ray_origin(m_pos)
	var ray_end = ray_start + cam.project_ray_normal(m_pos) * RAY_LENGTH
	var space_state = cam.get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.create(ray_start,ray_end)
	return space_state.intersect_ray(params)

## callback for selecting units using elements outside the SelectionSystem node tools (e.g. character portraits) ##
func __on_unit_selected(unit):
	if unit.is_in_group("units"):
		deselect_all_units()
		selected_units.append(unit)


func on_unit_died(unit):
	if selected_units.has(unit):
		selected_units.remove_at(selected_units.find(unit))
