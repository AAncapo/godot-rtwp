class_name State extends Node

signal changed(new_state:String, target, character)

var character: Character
var target


func enter():
	var ms
	var walk = character.walk_sp
	var run = character.run_sp
	var alert = character.alert_sp
	
	var sd
	var base = character.base_safdist
	var cmbtsd = character.combat_safdist
	
	match name.to_lower():
		'idle':
			ms=walk
			sd=base
		'combat':
			ms=walk
			sd=cmbtsd
		'search':
			ms=alert
			sd=base
		'cover':
			ms=run
			sd=base
		'move':
			ms=run
			sd=base
		'wander':
			ms=walk
			sd=base
	
	character.mov.move_speed = ms
	character.curr_safdist = sd
	
	print(character.name," entered ",name," state. Target = ",target if !target is Vector3 else "Vector3")


func exit():
	pass

func update(_delta:float):
	pass

func update_physics(_delta:float):
	pass
