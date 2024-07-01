extends Control

const BOX_COLOR = Color(1,1,1)
const BOX_LINE_WIDTH = 3
var _is_visible = false
var m_pos = Vector2()
var start_sel_pos = Vector2()


func _draw():
	if _is_visible and start_sel_pos != m_pos:
		draw_line(start_sel_pos, Vector2(m_pos.x, start_sel_pos.y), BOX_COLOR, BOX_LINE_WIDTH)
		draw_line(start_sel_pos, Vector2(start_sel_pos.x, m_pos.y), BOX_COLOR, BOX_LINE_WIDTH)
		draw_line(m_pos, Vector2(m_pos.x, start_sel_pos.y), BOX_COLOR, BOX_LINE_WIDTH)
		draw_line(m_pos, Vector2(start_sel_pos.x, m_pos.y), BOX_COLOR, BOX_LINE_WIDTH)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("left_click"):
		start_sel_pos = get_viewport().get_mouse_position()
	
	_is_visible = Input.is_action_pressed("left_click")
	if _is_visible: m_pos = get_viewport().get_mouse_position()
	
	queue_redraw() #TODO only if visible?


func get_generated_box():
	if m_pos.distance_squared_to(start_sel_pos) < 4: return null
	
	var top_left = start_sel_pos
	var bottom_right = m_pos
	if top_left.x > bottom_right.x:
		var tmp = top_left.x
		top_left.x = bottom_right.x
		bottom_right.x = tmp
	if top_left.y > bottom_right.y:
		var tmp = top_left.y
		top_left.y = bottom_right.y
		bottom_right.y = tmp
	var box = Rect2(top_left, bottom_right - top_left)
	return box
