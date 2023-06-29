extends Node

@onready var animationTree = $AnimationTree
var movementBlendPos: Vector2
var wpnHoldBlendpos
var recoilPos
var recoil: bool


func _process(_delta):
	animationTree.set("parameters/movement/blend_position", movementBlendPos)
	animationTree.set("parameters/weapon_hold/blend_position", wpnHoldBlendpos)
	#play recoil animation
#	animationTree.set("parameters/recoil/blend_position",recoilPos)
#	animationTree.set("parameters/recoilShot/active",recoil)


func set_wpnhold_pos(pos):
	wpnHoldBlendpos = pos

func set_move_pos(pos:Vector2):
	movementBlendPos = pos

func one_shot_recoil(_recoil: bool):
	animationTree.set("parameters/recoilShot/active", _recoil)
