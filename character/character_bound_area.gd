extends Area3D
# Used to handle mouse input and detect overlapping areas

const HOSTILE_COLOR := Color('e3003a')
const ALLY_COLOR := Color('9fe2ff')

@onready var cam:Camera3D = get_viewport().get_camera_3d()
@onready var tc: ProgressBar = %TurnCounter
@onready var _log := %log
@onready var sel_circle := $SelectionRing
@onready var marked_circle := %MarkedCircle
@onready var range_visual := %RangeVisualizer
@export_node_path("Timer") var turnTimer
var timer:Timer
var offset_pos := Vector2(-50,-320)
var name_color
var info_visible := false
var is_marked := false:
	set(value):
		is_marked = value
		if !is_marked:
			_animate_marker(false)


func _ready() -> void:
	await get_parent().ready
	get_parent().selected.connect(_on_character_selected)
	mouse_entered.connect(_on_mouse_over.bind(true))
	mouse_exited.connect(_on_mouse_over.bind(false))
	
	timer = get_node(turnTimer)
	set_unit_name()
	
	var sel_mat = sel_circle.get("surface_material_override/0")
	sel_mat.albedo_color = Global.player_team_color if get_parent().team == 0 else Global.hostile_team_color


func  _process(_delta: float) -> void:
	#var _is_visible = cam.is_position_in_frustum(global_position)
	
	%Control.visible = info_visible
	if info_visible:
		var pos = cam.unproject_position(%CharaHUD.global_position)
		%Control.global_position = pos + offset_pos
	
	if timer:
		update_turn_counter(timer.time_left, timer.wait_time)
		tc.visible = tc.value > tc.min_value and tc.value < tc.max_value
	
	if is_marked:
		marked_circle.rotate_y(_delta)


func get_current_room() -> Room:
	var areas = get_overlapping_areas()
	for a in areas:
		if a is Room:
			return a
	return null


func add_notification(pop=Global.POPUP_NOTIF.NORMAL, text:String="", remove=false):
	var label := Label.new()
	
	var lab_settings := LabelSettings.new()
	lab_settings.font_size = pop.fsize
	lab_settings.font_color = pop.fcolor
	lab_settings.outline_size = 1
	lab_settings.outline_color = pop.fcolor
	label.label_settings = lab_settings
	
	label.text = pop.text if text.length() <= 0 else text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	#if STUN pop exists avoid adding more
	if !pop.auto_fade:
		for lab in _log.get_children():
			if lab.text == pop.text:
				if remove:
					lab.queue_free()
				return
	
	_log.add_child(label)
	
	if pop.auto_fade:
		var t := get_tree().create_timer(1)
		await t.timeout
		var tween = get_tree().create_tween()
		tween.tween_property(label,"modulate", Color('ffffff00'), 1)
		await tween.finished
		label.queue_free()
	else:
		var tween := label.create_tween().set_loops()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(lab_settings, "font_size", 15, .1)
		tween.tween_property(lab_settings, "font_size", 10, .5)


func update_turn_counter(curr_val:float, max_val:float):
	tc.value = curr_val
	tc.max_value = max_val


func clear_notifications():
	tc.hide()
	for n in _log.get_children():
		n.hide()


func set_unit_name():
	name_color = ALLY_COLOR if get_parent().is_player() else HOSTILE_COLOR
	%Name.set("theme_override_colors/font_color",name_color)
	%Name.get("theme_override_styles/normal").set("border_color",name_color)
	%Name.text = get_parent().stats.alias.to_upper()


func _on_mouse_over(is_mouse_over:bool):
	#TODO hay un error que (solo en las player team units) impide mostrar el info on mouseover
	if !get_parent().is_selected: info_visible = is_mouse_over
	if get_parent().team != Global.PLAYER_TEAM:
		_animate_marker(is_mouse_over)


func _on_character_selected(sel: bool) -> void:
	info_visible = sel


func update_range_visual(radius:float):
	var subv := range_visual.get_node("SubViewport")
	var _size := Vector2.ONE * ((radius * 2) *100) 
	subv.size = _size
	%RangeArc.size = _size
	
	range_visual.visible = radius > 0
	if range_visual.visible:
		%RangeArc.radius = radius 


func _animate_marker(anim_in:bool):
	var start_val = Vector3.ONE * 1.2
	marked_circle.scale = start_val
	var tween := create_tween()
	
	if anim_in:
		marked_circle.modulate = Color("ffffff")
		marked_circle.show()
		var final_val= Vector3.ONE * 1.4
		tween.tween_property(marked_circle,"scale",final_val, .1)
		tween.tween_property(marked_circle,"scale",start_val, .2)
	else:
		if !is_marked:
			#tween.tween_property(marked_circle,"scale",Vector3.ZERO, .2)
			#tween.set_parallel(true)
			#tween.tween_property(marked_circle,"modulate",Color("ffffff00"), .1)
			#await tween.finished
			marked_circle.hide()
	tween.set_trans(Tween.TRANS_SINE)
