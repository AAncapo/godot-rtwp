class_name StateMachine extends Node 

signal state_changed(state)  #connected manually to GUI

@export var initial_state: State
var states: Dictionary = {}
var curr_state: State:
	set(new_state):
		if curr_state:
			curr_state.exit()
		if !new_state.character: new_state.character = owner
		new_state.enter()
		curr_state = new_state


func _ready():
	for state in get_children():
		if state is State:
			states[state.name.to_lower()] = state
			state.changed.connect(change_state)
	
	await owner.ready
	if initial_state:
		self.curr_state = initial_state


func _process(delta):
	if curr_state:
		curr_state.update(delta)

func _physics_process(delta):
	if curr_state:
		curr_state.update_physics(delta)


func change_state(new_state_name:String, target=null, character=owner):
	var new_state: State = states.get(new_state_name.to_lower())
	if !new_state:
		print('ERROR: Cannot find a State.',new_state_name)
		new_state = states.get('idle')
	
	GameEvents.update_clg.emit(get_parent().character,str('entered ',new_state.name,' state'),get_parent().character)
	state_changed.emit(new_state_name)
	
	new_state.target = target
	new_state.character = character
	self.curr_state = new_state
