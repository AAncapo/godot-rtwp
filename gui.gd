extends Control

@onready var portraits = %portraits
@onready var actions = %actions
@onready var fps = $fps
@onready var stats_display := %StatsDisplay
var portrait_tscn = preload("res://gui/portrait.tscn")
var action_button_tscn = preload("res://gui/action_button.tscn")


func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)


func _process(_delta):
	fps.text = str(Engine.get_frames_per_second(),"fps")
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var port = portrait_tscn.instantiate()
		portraits.add_child(port)
		port.text = unit.name
		port.pressed.connect(_on_portrait_pressed.bind(unit))
		unit.selected.connect(_on_character_selected.bind(unit))


func _on_portrait_pressed(unit):
	Global.gui_select_unit.emit(unit)

func _on_character_selected(sel:bool, unit):
	update_action_buttons(unit)
	
	%unitName.text = unit.name
	var textEdit := %TextEdit
	textEdit.text = ""
	var stats:Dictionary = unit.stats.get_stats_dictionary()
	for s in stats:
		textEdit.text += str(s,": ",stats[s],"\n")


func update_action_buttons(unit):
	for a in actions.get_children():
		a.queue_free()
	
	var unit_actions = unit.actions.get_children()
	for a in unit_actions:
		var btn = action_button_tscn.instantiate()
		actions.add_child(btn)
		var hotkey = str(a.get_index() + 1)
		btn.init(a, hotkey)
		btn.mouse_enter.connect(_on_action_mouse_enter)
		btn.mouse_exit.connect(_on_action_mouse_exit)


func _on_action_mouse_enter(btn_action):
	%ActionName.text = btn_action.action_name

func _on_action_mouse_exit():
	%ActionName.text = ""
