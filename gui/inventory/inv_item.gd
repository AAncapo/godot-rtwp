class_name InvItem extends Button

signal _is_dragging(_self)
signal mouseover(_self, _is_mouseover)


@onready var draggable = $draggable_icon
var item:Item:
	set(value):
		item = value
		if item:
			icon = item.icon
			draggable.texture = icon

func _ready() -> void:
	mouse_entered.connect(_is_mouse_over.bind(true))
	mouse_exited.connect(_is_mouse_over.bind(false))


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("left_click"):
			_is_dragging.emit(self)


func _is_mouse_over(is_mo:bool):
	mouseover.emit(self,is_mo)
