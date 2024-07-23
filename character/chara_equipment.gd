class_name CharacterEquipment extends Node3D

signal equipment_updated(_item:Item, set_equipped:bool, link_idx:int)

@export var starting_items:Array[PackedScene]
@onready var bones := $Bones
@onready var inventory := $Inventory
@onready var unarmed:Weapon = $Unarmed
var links:Dictionary
var equipped_wpn:Weapon:
	set(value):
		#when trying to get if wpn != null, get if weapon_class != UNARMED instead.
		equipped_wpn = value
		if !equipped_wpn: equipped_wpn = unarmed
		if equipped_wpn == unarmed: update_unarmed(%Stats)
var equipped_gear := {
	"Head"      :null,
	"Torso"     :null,
	"ShoulderR" :null,
	"LowerarmR" :null,
	"HandR"     :null,
	"ThighR"    :null,
	"ShinR"     :null,
	"ShoulderL" :null,
	"LowerarmL" :null,
	"HandL"     :null,
	"ThighL"    :null,
	"ShinL"     :null
	}
var quick_items := []


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
	
	await get_parent().ready
	
	for i in starting_items:
		var new_item = i.instantiate()
		inventory.add_child(new_item)
	for i in get_inventory_items():
		if i is Weapon:
			equipment_updated.emit(i, true, Stats.BL.HandR)
			break
	for i in get_inventory_items():
		if i is Gear:
			equipment_updated.emit(i, true, Stats.BL.Torso)
			break


func _process(_delta: float) -> void:
	for key in links.keys():
		if links[key].item != null:
			links[key].item.global_transform = links[key].offset.global_transform

#TODO [REFACTOR] I should either keep the equipment data on equipped_wpns/gear dicts or in links dicts
#maybe later when i start adding clothes idk
func equip(_item:Item, link_idx:int):
	var key: String = Stats.BL.keys()[link_idx]
	links[key].item = _item
	
	if _item is Weapon:
		equipped_wpn = _item
		equipped_wpn.init(get_parent())
	
	if _item.equipment_class == Item.EquipmentClass.GEAR:
		equipped_gear[key] = _item


func unequip(_item:Item):
	if _item != unarmed:
		for key in links.keys():
			if links[key].item == _item: links[key].item = null
		equipped_gear[equipped_gear.find_key(_item)] = null
		
		if _item is Weapon: equipped_wpn = unarmed


func update_unarmed(stats:Stats):
	var dice_amount := 1
	if stats.BODY <= 4: dice_amount = 1
	if stats.BODY in [5,6]: dice_amount = 2
	if stats.BODY in [7,10]: dice_amount = 3
	if stats.BODY >= 11: dice_amount = 4
	unarmed.dice_amount = dice_amount


func get_inventory_items():
	return inventory.get_children()
