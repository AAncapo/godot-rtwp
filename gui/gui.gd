extends Control

@onready var fps = $fps
@onready var portraits = %portraits
@onready var weapon_actions = %Weapon
@onready var actions := %Actions
var portrait_tscn = preload("res://gui/portrait.tscn")


func _ready() -> void:
	clear_buttons()
	Global.added_unit.connect(_on_added_unit)  #init portraits


func _process(_delta):
	fps.text = str(Engine.get_frames_per_second(),"fps")
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.is_player():
		var port = portrait_tscn.instantiate()
		portraits.add_child(port)
		port.unit = unit
		port.selected.connect(_on_unit_selected)


func _on_unit_selected(_unit):
	clear_buttons()
	
	weapon_actions.modulate = Color('ffffff')
	actions.modulate = Color('ffffff')
	
	if Global.selected_units.size() > 0:
		%Equipped.action = _unit.actions.get_child(_unit.actions.MAIN_ATTACK)
		%RangedClip.show()
		
		for a in _unit.actions.get_children():
			if a.get_index()>0:
				actions.get_child(a.get_index()-1).action = a


func clear_buttons():
	weapon_actions.modulate = Color('ffffff64')
	actions.modulate = Color('ffffff64')
	%Equipped.action = null
	%RangedClip.hide()
	for btn in actions.get_children():
		btn.action = null
