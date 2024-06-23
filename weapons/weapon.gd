class_name Weapon extends Node3D

@export var icon:Texture2D
@export var name_:String
@export var range_:float = 1
enum Reliability { NA, VR, ST, UR }  # (VeryReliabl, Standard, Unreliabl)
@export var reliabl := Reliability.NA
@export var related_skill:String
@export_category("Damage Calc")
@export var dice_amount:int = 1
enum Dice { D6 = 6, D10 = 10 }
@export var sides:Dice = Dice.D6
@export var modifier:int
var damage:int:
	get:
		randomize()
		var result:int = Fnff.roll(dice_amount, sides) + modifier
		return result

@onready var actions := $Actions
var _owner:Unit


func init(actor):
	_owner = actor
	actions.init(_owner)


func attack():
	pass
