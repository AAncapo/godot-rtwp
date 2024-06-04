class_name Unit extends CharacterBody3D

signal selected(is_selected:bool)
signal target_updated(new_target)

@export var team = 0

var target
var is_selected:bool =false:
	set(value):
		is_selected = value
		selected.emit(is_selected)


func _ready() -> void:
	selected.connect(_on_selected)


func update_target(val):
	target = val
	target_updated.emit(target)


func add_commands_listener():
	if !is_player(): return
	if !Global.command.is_connected(update_target):
		Global.command.connect(update_target)


func remove_commands_listener():
	if !is_player(): return
	if Global.command.is_connected(update_target):
		Global.command.disconnect(update_target)


func _on_selected(sel:bool):
	#is_selected = sel
	if sel: add_commands_listener()
	else: remove_commands_listener()


func is_enemy(unit):
	if unit.is_in_group(Global.UNIT_GROUP):
		if unit.team != team:
			return true
	return false

func is_leader(): return Global.player_leader == self

func is_player(): return team == Global.PLAYER_TEAM
