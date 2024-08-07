class_name InventoryUI extends Control

@export var stats_line_spacing:int = -5
@onready var chara_name := %CharacterName
@onready var slot_container := %SlotContainer
@onready var quick_items := %HBoxContainer
var equipment_slots := []
var inv_slot = preload("res://gui/inventory/inv_slot.tscn")
var inv_item = preload("res://gui/inventory/inv_item.tscn")
var _character:Character:
	set(value):
		if _character: #disconnect previous character signal
			if _character.stats.updated.is_connected(_on_stats_updated):
				_character.stats.updated.disconnect(_on_stats_updated)
		_character = value
		if _character and !_character.stats.updated.is_connected(_on_stats_updated):
			_character.stats.updated.connect(_on_stats_updated)
		if !_character: return #shouldnt be null at any point but warever
		chara_name.text = str(_character.stats.alias," ",_character.stats.name_)
		update_stats()
		update_slots()
var all_slots := []
var item_dragging:InvItem
var slot_target:InvSlot
var item_target:InvItem


func _ready() -> void:
	%Prev.pressed.connect(_on_prev_pressed)
	%Next.pressed.connect(_on_next_pressed)
	
	for es in %WeaponSlots.get_children():
		if es is InvSlot: equipment_slots.append(es)
	for es in %GearSlots.get_children():
		equipment_slots.append(es)
	
	all_slots.append_array(equipment_slots)
	all_slots.append_array(slot_container.get_children())
	for s in all_slots:
		s.mouseover.connect(_on_slot_mouseover)
	
	for label in %Stats.get_children():
		label.set("theme_override_constants/line_spacing",stats_line_spacing)


func _process(_delta: float) -> void:
	if !item_dragging:
		return
	
	var draggable = item_dragging.draggable
	var drag_pos = get_viewport().get_mouse_position() - Vector2(draggable.size.x/2, draggable.size.y/2)
	draggable.global_position = drag_pos
	
	if Input.is_action_just_released("left_click"): #item dropped
		drop_item()
		reset_dragging()


func update_slots():
	for es in equipment_slots: es.clear()
	for slot in slot_container.get_children(): slot.clear()
	for qis in quick_items.get_children(): qis.clear()
	
	var inventory = _character.equipment.get_inventory_items()
	
	for i in inventory:
		var item_btn = inv_item.instantiate()
		if !i.is_equipped:
			var s = slot_container.get_child(inventory.find(i))
			s.add_item(item_btn)
		else:
			for es in equipment_slots:
				#find slot that shares link key w item
				for key in _character.equipment.links.keys():
					var link = _character.equipment.links[key]
					if link.item == i and key == Stats.BL.keys()[es.link_idx]:
						es.add_item(item_btn)
			
			#Quick Items
			#if _character.equipment.quick_items.has(i):
				#for qis in quick_items.get_children():
					#qis.add_item(item_btn)
		item_btn.item = i
		item_btn._is_dragging.connect(_on_item_dragging)
		item_btn.mouseover.connect(_on_item_mouseover)


func _on_stats_updated():
	update_stats()
func update_stats():
	for label in %Stats.get_children() as Array[Label]:
		label.text = ""
	var stats := _character.stats
	for s in stats.starting_stats:
		for label in %Stats.get_children() as Array[Label]:
			match label.name:
				"key": label.text += str(s,"\n")
				"value": label.text += str(stats.get(s),"\n")
				"mod":
					var stat_mod = stats.get_stat_mods(s)
					if !stat_mod: 
						label.text += str("\n")
						continue
					label.text += str("(",str(stat_mod) if stat_mod < 0 else str("+",stat_mod),")\n")

# The weapons.body_location is set to HandR by default but is not taken into consideration at any point
#when equipping a weapon the only thing that needs to know which hand it belongs to its the slot
func drop_item():
	if item_target and item_dragging.get_parent() == item_target:
		return #dropped in the same slot
	if !slot_target and !item_target:
		return #dropped in an unavailable point
	
	var curr_slot_cl = item_dragging.get_parent().compatible_equipmt_class
	
	if slot_target: #target is EMPTY slot
		if slot_target.compatible_equipmt_class==Item.EquipmentClass.GEAR and item_dragging.item.body_location != slot_target.link_idx:
			return
		if slot_target.compatible_equipmt_class==Item.EquipmentClass.WEAPON and !item_dragging.item is Weapon:
			return
		#unequip if current slot is an equipmnt slot (was equipped)
		if curr_slot_cl != Item.EquipmentClass.ANY:
			_character.equipment.equipment_updated.emit(item_dragging.item, false)
		# equip if target slot parent is equipmnt slot
		if slot_target.compatible_equipmt_class != Item.EquipmentClass.ANY:
			_character.equipment.equipment_updated.emit(item_dragging.item, true, slot_target.link_idx)
	
	if item_target: #target is OCCUPIED slot
		slot_target = item_target.get_parent()
		if slot_target.compatible_equipmt_class==Item.EquipmentClass.GEAR and item_dragging.item.body_location != slot_target.link_idx:
			return
		if slot_target.compatible_equipmt_class==Item.EquipmentClass.WEAPON and !item_dragging.item is Weapon:
			return
		if slot_target.compatible_equipmt_class != Item.EquipmentClass.ANY:
			# Unequip existent item in slot target
			_character.equipment.equipment_updated.emit(item_target.item, false)
			if curr_slot_cl == slot_target.compatible_equipmt_class:
				# Re-Equip that item in the other slot if is the same class
				_character.equipment.equipment_updated.emit(item_target.item, true, item_dragging.get_parent().link_idx)
		
			_character.equipment.equipment_updated.emit(item_dragging.item, true, slot_target.link_idx)
	
	slot_target.add_item(item_dragging)
	
	#TODO add set to equipped unequipped if quick slot and add/remove from quick items in equipment


func reset_dragging():
	var draggable = item_dragging.draggable
	draggable.global_position = item_dragging.global_position
	item_dragging = null


func _on_item_dragging(item_btn:InvItem):
	item_dragging = item_btn
	#search and highlight the compatible slots in equipment
	#var equipmt_class = item_btn.item.equipment_class
	#for s in equipment_slots:
		#if equipmt_class == s.compatible_equipmt_class:
			#s.highlight()


func _on_slot_mouseover(_slot, is_mo:bool):
	slot_target = _slot if is_mo else null


func _on_next_pressed():
	var idx = Global.player_units.find(_character) + 1
	if idx >= Global.player_units.size(): idx = 0
	_character = Global.player_units[idx]


func _on_prev_pressed():
	var idx = Global.player_units.find(_character) - 1
	if idx < 0: idx = Global.player_units.size()-1
	_character = Global.player_units[idx]

func _on_item_mouseover(_item,is_mo:bool):
	item_target = _item if is_mo else null


func _on_visibility_changed() -> void:
	if self.visible:
		if !_character:
			_character = Global.player_units[0]


func is_quickitem_slot(_slot:InvSlot):
	if _slot.get_parent() == quick_items:
		return true
