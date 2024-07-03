extends Node3D

@export_node_path("Skeleton3D") var skeleton_path
@onready var inventory = $Inventory
var links:Dictionary
var equipped_wpn:Weapon

@export var unarmed_range:float
@export var unarmed_icon:Texture2D


func _ready() -> void:
	if !skeleton_path:
		printerr("Failed to link bones to nodes: A Skeleton needs to be assigned")
		get_tree().quit()
		return
	var skeleton = get_node_or_null(skeleton_path)
	
	for bone_att in skeleton.get_children():
		if bone_att is BoneAttachment3D and bone_att.get_child_count() > 0:
			var offset: Node3D = bone_att.get_child(0)
			links[bone_att.name] = {
				"bone"  : bone_att,
				"offset": offset,
				"item"  : null
				}
		else: continue


func _process(delta: float) -> void:
	for key in links.keys():
		if links[key].item != null:
			links[key].item.global_transform = links[key].offset.global_transform


func equip(_item:Item, link_key:String):
	if _item is Weapon:
		equipped_wpn = _item
		equipped_wpn.init(get_parent())
	
		links[link_key].item = _item


func unequip(_item:Item):
	for key in links.keys():
		if links[key].item == _item:
			links[key].item = null


func get_inventory_items():
	return inventory.get_children()
