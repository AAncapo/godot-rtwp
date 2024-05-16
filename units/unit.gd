class_name Unit extends CharacterBody3D

signal selected(sel:bool)
signal target_updated(new_target)

@export var team = 0

var target
var is_selected:bool =false
var is_mouseover:bool = false


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func update_target(val):
	target = val
	target_updated.emit(target)


func is_enemy(unit) -> bool:
	if unit.is_in_group(Global.UNIT_GROUP):
		if unit.team == Global.ENEMY_TEAM:
			return true
	return false


func add_commands_listener():
	if team != 0: return
	if !Global.command.is_connected(update_target):
		Global.command.connect(update_target)


func remove_commands_listener():
	if team != 0: return
	if Global.command.is_connected(update_target):
		Global.command.disconnect(update_target)


func _on_mouse_entered():
	_on_mouse_over(true)
func _on_mouse_exited():
	_on_mouse_over(false)
func _on_mouse_over(mo:bool):
	pass
