class_name Item extends Node3D

enum EquipmentClass { ANY, WEAPON, GEAR }
@export var equipment_class = EquipmentClass.WEAPON
@export var body_location:Stats.BL
@export var name_:String
@export var description:String
@export var icon:Texture2D
@export var cost:float
var id:int
var is_equipped:bool = false:
	set(value):
		is_equipped = value
		visible = is_equipped


func _init() -> void:
	visible = is_equipped
