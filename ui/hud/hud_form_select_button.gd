extends Button

@export var form_index : int

func _on_pressed():
	GameEvents.emit_signal("form_selected", form_index)
	print('formation ', form_index,' selected')
