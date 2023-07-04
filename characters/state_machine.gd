extends Node
class_name StateMachine

@export var initial_state: State

var states: Dictionary = {}
var current_state: State:
	set(new_state):
		if current_state:
			current_state.exit()
		new_state.enter()
		current_state = new_state


func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.changed.connect(change_state)
	
	await get_tree().create_timer(1.0,true).timeout
	if initial_state:
		current_state = initial_state


func _process(delta):
	if current_state:
		current_state.update(delta)


func _physics_process(delta):
	if current_state:
		current_state.update_physics(delta)


func change_state(new_state_name:String):
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		print('ERROR: Cannot find a State.',new_state_name)
		new_state = states.get('idle')
	
	current_state = new_state
