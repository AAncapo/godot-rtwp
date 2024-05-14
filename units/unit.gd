class_name Unit extends CharacterBody3D

signal selected(sel:bool)
signal target_updated(new_target)

@export var team = 0

var target


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
	if !GameEvents.command.is_connected(update_target):
		GameEvents.command.connect(update_target)


func remove_commands_listener():
	if team != 0: return
	if GameEvents.command.is_connected(update_target):
		GameEvents.command.disconnect(update_target)
