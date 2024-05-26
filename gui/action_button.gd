extends Control

signal mouse_enter(_action)
signal mouse_exit

@onready var button: Button = $Button
@onready var hotkey: Label = $Button/hotkey
@onready var options: VBoxContainer = $PanelContainer/Options
var action: Action
var set_hotkey:
	set(value):
		set_hotkey = value
		hotkey.text = value
		
		button.shortcut = Shortcut.new()
		var input_key = InputEventKey.new()
		input_key.keycode = value.unicode_at(0)
		button.shortcut.events = [input_key]

func init(_action, key):
	action = _action
	button.disabled = !action.is_available
	action.set_available.connect(_on_action_available)
	#button.tooltip_text = str(action.action_name,": ",action.action_description)
	set_hotkey = key
	
	if action.options.size() > 0:
		for option in action.options:
			pass
			var option_button = Button.new()
			options.add_child(option_button)
			option_button.text = option
			option_button.pressed.connect(_on_option_pressed.bind(option))

func _on_button_pressed() -> void:
	action.selected.emit(action)
	if action.options:
		$PanelContainer.visible = !$PanelContainer.visible

func _on_option_pressed(option):
	action.selected_option = option
	action.selected.emit(action)
	$PanelContainer.hide()

func _on_action_available(avail:bool):
	button.disabled = !avail


func _on_button_mouse_entered() -> void:
	mouse_enter.emit(action)

func _on_button_mouse_exited() -> void:
	mouse_exit.emit()
