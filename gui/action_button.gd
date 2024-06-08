extends Button

@onready var hotkey_view := %hotkey
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
		if !icon: text = action.action_name
		disabled = !action.enabled
		$count.text = str(action.count) if action.count else ""
		if !action.count_updated.is_connected(_on_count_updated):
			action.count_updated.connect(_on_count_updated)
var hotkey:
	set(value):
		hotkey = value
		if hotkey:
			hotkey_view.show()
			hotkey_view.text = hotkey
			return
		hotkey_view.hide()


func _on_pressed() -> void:
	action.select()


func _on_action_enabled(is_enabled:bool):
	disabled = !is_enabled


func _on_count_updated(_count):
	$count.text = str(_count)
