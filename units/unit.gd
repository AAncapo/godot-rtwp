class_name Unit extends CharacterBody3D

signal selected
signal deselected
signal target_updated(new_target)

@export var team = 0

var target


func set_target(target):
	self.target = target
	target_updated.emit(target)
#func set_target(value, emit_updated_signal=true):
	#target = value
	#if emit_updated_signal:
		#target_updated.emit(value,updated_manually)

func is_enemy(unit) -> bool:
	if unit.is_in_group('units'):
		if unit.team != team && unit.team < 2 && self.team != 2:
			return true
	return false


func add_commands_listener():
	if team != 0: return
	
	if !GameEvents.command.is_connected(set_target):
		GameEvents.command.connect(set_target)


func remove_commands_listener():
	if team != 0: return
	
	if GameEvents.command.is_connected(set_target):
		GameEvents.command.disconnect(set_target)
