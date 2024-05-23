extends Control

@onready var portraits = %portraits
@onready var actions = $Control/VBoxContainer/actions
@onready var fps = $fps
var portrait_tscn = preload("res://gui/portrait.tscn")


func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)


func _process(_delta):
	fps.text = str("fps: ",Engine.get_frames_per_second())
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var port = portrait_tscn.instantiate()
		portraits.add_child(port)
		port.unit = unit
		port.pressed.connect(_on_portrait_pressed.bind(unit))
		unit.selected.connect(_on_character_selected.bind(unit))


func _on_portrait_pressed(unit):
	Global.gui_select_unit.emit(unit)

func _on_character_selected(sel:bool, unit):
	update_action_buttons(unit)


func update_action_buttons(unit):
	for a in actions.get_children():
		a.queue_free()
	
	var unit_actions = unit.actions.get_children()
	for a in unit_actions:
		var abutton = Button.new()
		abutton.text = a.action_name
		abutton.tooltip_text = a.action_description
		actions.add_child(abutton)
		abutton.pressed.connect(_on_action_pressed.bind(a.action_name))


func _on_action_pressed(action_name:String):
	for u in Global.selected_units:
		u.select_action(action_name)
		$Control/VBoxContainer/ActionDescription.text = action_name
