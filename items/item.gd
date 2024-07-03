class_name Item extends Node3D

var id:int
@export var name_:String
@export var icon:Texture2D
var is_equipped:bool = false:
	set(value):
		is_equipped = value
		visible = is_equipped
enum EquipmentClass { ANY, WEAPON, HEAD, TORSO }
@export var equipment_class = EquipmentClass.WEAPON


func _init() -> void:
	visible = is_equipped
	randomize()
	id = randi_range(0,999999)
