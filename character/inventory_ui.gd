class_name InventoryUI extends Control

signal equipment_updated(_item:Item, set_equipped:bool)

@onready var chara_name := %CharacterName
@onready var slot_container := %SlotContainer
var equipment_slots := []
var inv_slot = preload("res://gui/inventory/inv_slot.tscn")
var inv_item = preload("res://gui/inventory/inv_item.tscn")
var _character:Character:
	set(value):
		if _character:
			if equipment_updated.is_connected(_character._on_equipment_updated):
				equipment_updated.disconnect(_character._on_equipment_updated)
		
		_character = value
		if !_character: return #shouldnt be null at any point but warever
		
		equipment_updated.connect(_character._on_equipment_updated)
		chara_name.text = str(_character.stats.alias," ",_character.stats.name_)
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
	for es in equipment_slots:
		es.clear()
	for slot in slot_container.get_children():
		slot.clear()
	
	for i in _character.inventory.items:
		var s = slot_container.get_child(_character.inventory.items.find(i))
		var item_btn = inv_item.instantiate()
		s.add_item(item_btn)
		item_btn.item = i
		item_btn._is_dragging.connect(_on_item_dragging)
		item_btn.mouseover.connect(_on_item_mouseover)


func drop_item():
	## Para slots con items es necesario comprobar el item_target.get_parent() / si el slot tiene un item no emite la signal de mouseover (el item(child) consume el InputEvent)
	if item_target and item_dragging.get_parent() == item_target:
		return #dropped in the same slot
	if !slot_target and !item_target:
		return #dropped in an unavailable point
	
	var dragged_item_cl = item_dragging.item.equipment_class
	var curr_slot_cl = item_dragging.get_parent().compatible_equipmt_class
	
	if slot_target: #target is EMPTY slot
		var target_slot_cl = slot_target.compatible_equipmt_class
		# If item & slot cls are compatible or slot cls is ANY -- OK
		if dragged_item_cl == target_slot_cl or target_slot_cl == Item.EquipmentClass.ANY:
			# unequip if current slot parent is equipmnt slot
			if curr_slot_cl != Item.EquipmentClass.ANY:
				equipment_updated.emit(item_dragging.item, false)
			# equip if target slot parent is equipmnt slot
			if slot_target.compatible_equipmt_class != Item.EquipmentClass.ANY:
				equipment_updated.emit(item_dragging.item, true)
			slot_target.add_item(item_dragging)
	
	if item_target: #target is OCCUPIED slot
		if item_target.get_parent().compatible_equipmt_class != Item.EquipmentClass.ANY:
			# Unequip existent item in slot target
			equipment_updated.emit(item_target.item, false)
			
			if curr_slot_cl == item_target.get_parent().compatible_equipmt_class:
				# If current slot & target item.slt class are equal (swapping hands)..
				# equip again the target item
				equipment_updated.emit(item_target.item, true)
			
			equipment_updated.emit(item_dragging.item, true)
			
		item_target.get_parent().add_item(item_dragging)


func reset_dragging():
	var draggable = item_dragging.draggable
	draggable.global_position = item_dragging.global_position
	item_dragging = null


func _on_next_pressed():
	var idx = Global.player_units.find(_character) + 1
	if idx >= Global.player_units.size(): idx = 0
	_character = Global.player_units[idx]

func _on_prev_pressed():
	var idx = Global.player_units.find(_character) - 1
	if idx < 0: idx = Global.player_units.size()-1
	_character = Global.player_units[idx]


func _on_visibility_changed() -> void:
	if self.visible:
		if !_character:
			_character = Global.player_units[0]


func _on_item_dragging(item_btn:InvItem):
	item_dragging = item_btn
	#search and highlight the compatible slots in equipment
	var equipmt_class = item_btn.item.equipment_class
	for s in equipment_slots:
		if equipmt_class == s.compatible_equipmt_class:
			s.highlight()


func _on_slot_mouseover(_slot, is_mo:bool):
	slot_target = _slot if is_mo else null

func _on_item_mouseover(_item,is_mo:bool):
	item_target = _item if is_mo else null
