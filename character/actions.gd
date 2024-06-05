extends Node

enum { 
	MAIN_ATTACK, 
	CROUCH, 
	TAKEDOWN, 
	SWITCH_TO_SIDEARM 
	}
var selected_action = MAIN_ATTACK:
	set(value):
		selected_action = value
		get_child(selected_action).selected.emit()
