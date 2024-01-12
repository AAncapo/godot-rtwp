class_name Unit extends CharacterBody3D

signal selected
signal deselected
signal select_as_target
signal deselect_as_target
signal target_updated(new_target, manual)

@export var team = 0
@export var team_color: Color = Color(1,1,1,1)
var updated_manually:bool
## assign the target here so the char has a reference to the latest command received
## use to exit the run&gun state: if Input doubleclick -> force_to=true charAI.target_char = null -> charAI.target_char = new_target(vector3/collisionObj3D)
var target

func set_target(value, emit_updated_signal=true):
	target = value
	if emit_updated_signal:
		target_updated.emit(value,updated_manually)

func is_enemy(unit) -> bool:
	if unit.is_in_group('units'):
		if unit.team != team && unit.team < 2 && team != 2:
			return true
	return false
