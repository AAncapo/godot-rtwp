extends State
class_name Wander

var move_speed: float
var move_direction: Vector3
var wander_time: float


func enter():
	randomize()
	move_speed = _char.walk_spd
	randomize_wander()


func update(delta:float):
	if wander_time > 0:
		wander_time -= delta
	else:
		randomize_wander()


func randomize_wander():
	var r = 5.0
	move_direction = Vector3(randf_range(-r,r),owner.global_position.y,randf_range(-r,r))
	wander_time = randf_range(4,6)
	_char.target = move_direction


func exit():
	super.exit()
