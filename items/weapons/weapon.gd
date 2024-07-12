class_name Weapon extends Item
#CPRED Corebook (pg176)
#With the exception of Very Heavy Melee Weapons, all Melee combat is 2 ROF, allowing for 2 strikes to be made with every Attack Action. Targets must be in your reach (2m/yards)
enum WeaponClass { UNARMED, MELEE, RANGED }
@export var weapon_class:WeaponClass
@export var range_:float = 1
enum Reliability { NA, VERY_RELIABLE, STANDARD, UNRELIABLE }
@export var reliabl:Reliability
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
