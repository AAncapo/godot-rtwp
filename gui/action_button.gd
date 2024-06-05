extends Button

var action: Action:
	set(value):
		action = value
		if !action:
			icon = null
			disabled = true
			return
		if !action.set_enabled.is_connected(_on_action_enabled):
			action.set_enabled.connect(_on_action_enabled)
		icon = action.icon
		disabled = !action.enabled
var hotkey:
	set(value):
		hotkey = value
		if hotkey:
			%hotkey.show()
			%hotkey.text = hotkey
			return
		%hotkey.hide()
var amount:int


func _on_pressed() -> void:
	action.select()


func _on_action_enabled(is_enabled:bool):
	disabled = !is_enabled
