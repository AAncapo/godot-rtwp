extends Node

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	## F - show/hide formations tab in UI
	if event.is_action_pressed("toggle_form_tab"):
		GameEvents.emit_signal("ui_toggle_form_tab")
	if event.is_action_pressed("ui_toggle_combat_log"):
		GameEvents.ui_toggle_combat_log.emit()
	
