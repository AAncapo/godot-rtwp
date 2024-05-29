class_name Unit extends CharacterBody3D

signal selected(sel:bool)
signal target_updated(new_target)

@export var team = 0

var target
var is_selected:bool =false


func _ready() -> void:
	selected.connect(_on_selected)


func update_target(val):
	target = val
	target_updated.emit(target)


func is_enemy(unit):
	if unit.is_in_group(Global.UNIT_GROUP):
		if unit.team != team:
			return true
	return false


func is_ally(unit):
	if unit.is_in_group(Global.UNIT_GROUP):
		if unit.team == team:
			return true
	return false


func add_commands_listener():
	if team != Global.PLAYER_TEAM: return
	if !Global.command.is_connected(update_target):
		Global.command.connect(update_target)


func remove_commands_listener():
	if team != Global.PLAYER_TEAM: return
	if Global.command.is_connected(update_target):
		Global.command.disconnect(update_target)

func _on_selected(sel:bool):
	is_selected = sel
	if sel: add_commands_listener()
	else: remove_commands_listener()
