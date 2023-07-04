extends Node
class_name State

signal changed(new_state:String)

var _char: Character
var mov: CharacterMovement
var wpn_ctrl: WeaponController
var da: DetectionArea

var target_char: Character
var target_pos: Vector3
var rungun: bool = true

func enter():
	pass

func exit():
	pass

func update(_delta:float):
	pass

func update_physics(_delta:float):
	pass
