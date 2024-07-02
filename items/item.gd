class_name Item extends Node3D

var id:int
@export var name_:String
@export var icon:Texture2D
var is_equipped:bool = false
enum EquipmentClass { ANY, WEAPON, HEAD, TORSO }
@export var equipment_class = EquipmentClass.WEAPON


func _init() -> void:
	randomize()
	id = randi_range(0,999999)
