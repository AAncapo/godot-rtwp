class_name Wander extends State

var wander_time:float


func enter():
	super.enter()
	randomize()
	randomize_wander()


func update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()


func randomize_wander():
	var r = 5.0
	var move_direction = Vector3(randf_range(-r,r),character.global_position.y,randf_range(-r,r))
	wander_time = randf_range(4,6)
	character.set_target(character.global_position + move_direction, false) 


func exit():
	super.exit()
