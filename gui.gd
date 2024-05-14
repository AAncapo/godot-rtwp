extends Control

@onready var portraits = $Control/HBoxContainer/portraits
@onready var actions = $Control/HBoxContainer/actions
var portrait_tscn = preload("res://gui/portrait.tscn")


func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)


func _process(_delta):
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var p = portrait_tscn.instantiate()
		portraits.add_child(p)
		p.name = str("pcharacter", p.get_child_count())
		p.pressed.connect(_on_character_selected.bind(unit))
	
	#update_actions(unit)


func update_actions(unit):
	#for act in actions.get_children():
		#if selected character has action => visible=true
		pass


func _on_character_selected(unit):
	Global.gui_select_unit.emit(unit)
	update_actions(unit)


func _on_equip_hgun_pressed() -> void:
	if Global.selected_units.size() > 0:
		var unit = Global.selected_units[0]
		if unit and unit.team == Global.PLAYER_TEAM: unit.equip("handgun")


func _on_equip_lmg_pressed() -> void:
	if Global.selected_units.size() > 0:
		var unit = Global.selected_units[0]
		if unit and unit.team == Global.PLAYER_TEAM: unit.equip("lmg")
