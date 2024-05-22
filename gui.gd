extends Control

@onready var portraits = %portraits
@onready var actions = $Control/VBoxContainer/actions
@onready var fps = $fps
var portrait_tscn = preload("res://gui/portrait.tscn")

func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)
	%stealth.toggled.connect(_on_stealth_toggled)
	
	#TODO: put this in a actionButton node script when time comes
	var action_butons = $Control/VBoxContainer/actions/BasicActions.get_children()
	action_butons.append_array(%SpecialActions.get_children())
	for ab in action_butons:
		if ab is Button:
			ab.mouse_entered.connect(update_description.bind(ab.tooltip_text))
			ab.pressed.connect(update_description.bind(ab.tooltip_text))
			ab.toggled.connect(update_description.bind(ab.tooltip_text))


func _process(_delta):
	fps.text = str("fps: ",Engine.get_frames_per_second())
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var p = portrait_tscn.instantiate()
		portraits.add_child(p)
		p.unit = unit
		p.pressed.connect(_on_character_selected.bind(unit))


func _on_character_selected(unit):
	Global.gui_select_unit.emit(unit)


func _on_stealth_toggled(toggled_on: bool) -> void:
	for unit in Global.selected_units:
		if unit.team == Global.PLAYER_TEAM:
			unit.stealth_active = toggled_on
			
			%takedown_mode.disabled = !toggled_on

func _on_takedown_mode_toggled(toggled_on: bool) -> void:
	for unit in Global.selected_units:
		var current_td = unit.takedown_mode
		unit.takedown_mode = unit.NONLETHAL_TD if current_td == unit.LETHAL_TD else unit.LETHAL_TD
		%takedown_mode.tooltip_text = str(unit.takedown_mode)


func update_description(action_name:String):
	$Control/VBoxContainer/ActionDescription.text = action_name
