class_name InvSlot extends Button

signal mouseover(_self, _is_mouseover)

@export var compatible_equipmt_class = Item.EquipmentClass.ANY
var item:InvItem


func _ready() -> void:
	mouse_entered.connect(_is_mouse_over.bind(true))
	mouse_exited.connect(_is_mouse_over.bind(false))


func add_item(new_item:InvItem):
	if new_item.get_parent() != null:
		if item:
			item.reparent(new_item.get_parent(),false)
		new_item.reparent(self,false)
		item = new_item
		return
	item = new_item
	add_child(item)


func highlight():
	button_pressed = true

func clear():
	if get_child_count()>0:
		for c in get_children():
			c.queue_free()
	item = null


func _is_mouse_over(is_mo:bool):
	mouseover.emit(self, is_mo)
