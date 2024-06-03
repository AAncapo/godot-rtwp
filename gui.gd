extends Control

@onready var portraits = %portraits
@onready var actions = %actions
@onready var abilities = %abilities
@onready var fps = $fps
var portrait_tscn = preload("res://gui/portrait.tscn")
var action_button_tscn = preload("res://gui/action_button.tscn")


func _ready() -> void:
	Global.added_unit.connect(_on_added_unit)  #init portraits


func _process(_delta):
	fps.text = str(Engine.get_frames_per_second(),"fps")
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.team == Global.PLAYER_TEAM:
		var port = portrait_tscn.instantiate()
		portraits.add_child(port)
		port.unit = unit
		port.selected.connect(_on_portrait_selected)


func _on_portrait_selected():
	#check Global for selected units and show/hide buttons accordingly
	for unit in Global.selected_units:
		pass

#func update_action_buttons(unit):
	#for a in actions.get_children():
		#a.queue_free()
	#
	#var unit_actions = unit.actions.get_children()
	#for a in unit_actions:
		#var btn = action_button_tscn.instantiate()
		#actions.add_child(btn)
		#var hotkey = str(a.get_index() + 1)
		#btn.init(a, hotkey)
