extends Node3D

@export_node_path("Skeleton3D") var skeleton_path
@export_node_path("Node") var inventory_path
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
				"bone":bone_att,
				"offset":offset
				}
		else: continue


func equip(_item:Item):
	#compare item type and find appropiate slot
	if _item is Weapon:
		equipped_wpn = _item
		equipped_wpn.init(get_parent())
	
	var handr = links["HandR"].offset
	_item.reparent(handr, false)


func unequip(_item:Item):
	if !inventory_path: printerr("Failed to get Inventory: An Inventory needs to be assigned")
	var inventory = get_node_or_null(inventory_path)
	_item.reparent(inventory.get_child(0), false)
