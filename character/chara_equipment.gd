class_name CharacterEquipment extends Node3D

signal equipment_updated(_item:Item, set_equipped:bool, link_key:String)

@onready var bones := $Bones
@onready var inventory = $Inventory
var links:Dictionary
var equipped_wpn :Weapon
var equipped_gear := {
	"Head"      :null,
	"Torso"     :null,
	"ShoulderR" :null,
	"LowerarmR" :null,
	"HandR"     :null,
	"ShoulderL" :null,
	"LowerarmL" :null,
	"HandL"     :null,
}
@export var unarmed_range:float
@export var unarmed_icon:Texture2D


func _ready() -> void:
	for bone_att in bones.get_children():
		if bone_att is BoneAttachment3D and bone_att.get_child_count() > 0:
			var offset: Node3D = bone_att.get_child(0)
			links[bone_att.name] = {
				"bone"  : bone_att,
				"offset": offset,
				"item"  : null
				}
		else: continue


func _process(_delta: float) -> void:
	for key in links.keys():
		if links[key].item != null:
			links[key].item.global_transform = links[key].offset.global_transform


func equip(_item:Item, link_idx:int):
	var key: String = Stats.BL.keys()[link_idx]
	links[key].item = _item
	
	if _item is Weapon:
		equipped_wpn = _item
		equipped_wpn.init(get_parent())
	
	if _item.equipment_class == Item.EquipmentClass.GEAR:
		equipped_gear[key] = _item


func unequip(_item:Item):
	for key in links.keys():
		if links[key].item == _item: links[key].item = null
	
	if _item is Weapon:
		equipped_wpn = null


func get_inventory_items():
	return inventory.get_children()
