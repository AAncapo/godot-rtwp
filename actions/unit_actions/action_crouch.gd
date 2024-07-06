extends Action


func execute():
	actor.stealth_on = !actor.stealth_on
	
	super.execute()


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("crouch") and actor.is_player() and actor.is_selected:
		execute()
