extends Control

@onready var port_btn := %Button
@onready var stylebox = port_btn.get("theme_override_styles/normal")
@onready var image:TextureRect = %image
#TODO  creo q la unica razon por la q el character tiene una signal on selected action updated es pa actualizar este label
#@onready var current_action_view: Button = %CurrentAction
@onready var wound_status := image.material
var character:Character:
	set(value):
		character = value
		if character:
			character.stats.updated.connect(_on_stats_updated)
			Global.unit_died.connect(_on_unit_died)
			image.texture = character.stats.portrait_image
			#character.selected_action_updated.connect(_on_selected_action_updated)


func _ready() -> void:
	Global.unit_selected.connect(_on_Global_unit_selected)
	Global.unit_deselected.connect(_on_Global_unit_deselected)


func _on_stats_updated():
	var stats:Stats = character.stats
	
	var body_pts = %BodyPts.get_children()
	var visible_pts := []
	#initialize body points
	for point in stats.BODY:
		body_pts[point].show()
		body_pts[point].get("theme_override_styles/normal").set("draw_center",true)
		visible_pts.append(point)
	#update based on current hp
	var step = stats.hitpoints / stats.BODY
	
	
	match stats.wounded_state:
		Stats.WoundedState.ANY:
			pass
		Stats.WoundedState.LIGHT:
			#light grey? LIGHLTY WOUNDED
			pass
		Stats.WoundedState.SERIOUS:
			#dark yellow
			pass
		Stats.WoundedState.MORTAL:
			#red
			pass
	#grayscale shader in character portrait
	#var step = 1.0 / stats.WoundedState.size()
	#var ws_idx = stats.wounded_state
	#var percent = (stats.WoundedState.size()-ws_idx) * step
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.tween_property(wound_status,"shader_parameter/percentage",percent, .1)
	%HP.text = str(stats.current_hp,"/",stats.hitpoints)
	
	var death_door = stats.wounded_state == Stats.WoundedState.MORTAL
	var anim = "mortal_alert" if death_door else "RESET"
	%AnimationPlayer.play(anim)


#func _on_selected_action_updated(action:Action):
	#current_action_view.text = action.action_name if action else ""
	#current_action_view.icon = action.icon if action else null


func _on_unit_died(_unit):
	if _unit == character:
		%Label.text = "FLATLINED"
		%AnimationPlayer.play("flatlined")


func _on_Global_unit_selected(_unit):
	if _unit == character:
		play_on_selected_tween(4)
		Global.select_unit(character)

func _on_Global_unit_deselected(_unit):
	if _unit == character:
		play_on_selected_tween(0)
		Global.deselect_unit(character)


func _on_button_mouse_entered() -> void:
	pass
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.tween_property(image, "scale", image.scale * 1.05, .2)


func _on_button_mouse_exited() -> void:
	pass
	#var tween = create_tween()
	#tween.set_trans(Tween.TRANS_SINE)
	#tween.tween_property(image, "scale", Vector2(1,1), .1)


func _on_button_pressed() -> void:
	#TODO check if pressing 'multi-select'
	await Global.deselect_all_units()
	Global.unit_selected.emit(character)


func play_on_selected_tween(desired_width):
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel(true)
	tween.tween_property(stylebox, "border_width_left", desired_width, .1)
	tween.tween_property(stylebox, "border_width_top", desired_width, .1)
	tween.tween_property(stylebox, "border_width_right", desired_width, .1)


func _on_button_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click:
		Global.unit_focused.emit(character.global_position)
