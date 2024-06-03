extends Node3D

const HOSTILE_COLOR := Color('e3003a')
const ALLY_COLOR := Color('9fe2ff')

@onready var cam:Camera3D = get_viewport().get_camera_3d()
@onready var tc: ProgressBar = %TurnCounter
@onready var _log := %log
@export_node_path("Timer") var turnTimer
var timer:Timer
var offset_pos := Vector2(-50,-320)
var name_color


func _ready() -> void:
	await get_parent().ready
	timer = get_node(turnTimer)
	
	name_color = ALLY_COLOR if get_parent().team==Global.PLAYER_TEAM else HOSTILE_COLOR
	%Name.set("theme_override_colors/font_color",name_color)
	%Name.get("theme_override_styles/normal").set("border_color",name_color)
	%Name.text = get_parent().stats.alias.to_upper()


func  _process(_delta: float) -> void:
	var _is_visible = cam.is_position_in_frustum(global_position)
	$Control.visible = _is_visible
	
	if _is_visible:
		var pos = cam.unproject_position(global_position)
		$Control.global_position = pos + offset_pos
	
	if timer:
		update_turn_counter(timer.time_left, timer.wait_time)
		tc.visible = tc.value > tc.min_value and tc.value < tc.max_value


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
