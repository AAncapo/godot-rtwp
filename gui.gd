extends Control

@onready var portraits = %portraits
@onready var actions = %actions
var portrait_tscn = preload("res://gui/portrait.tscn")


func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)

func _process(_delta):
	$Paused.visible = get_tree().paused

func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var p = portrait_tscn.instantiate()
		portraits.add_child(p)
		p.unit = unit
		p.pressed.connect(_on_character_selected.bind(unit))


func _on_character_selected(unit):
	Global.gui_select_unit.emit(unit)
	#update_actions(unit)

#func update_actions(unit):
	#pass

func _on_stealth_pressed() -> void:
	for unit in Global.selected_units:
		if unit.team == Global.PLAYER_TEAM:
			unit.stealth_active = !unit.stealth_active
