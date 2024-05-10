extends AnimationTree

var is_armed:bool = false
var current_state:String = "Normal"

func move(run:bool=false):
	if get("parameters/State/blend_amount") < 1:
		#is allowing Normal
		current_state = "Normal"
	else:
		current_state = "Alert"
	
	set(str("parameters/",current_state.capitalize(),"/blend_position"),1 if run else 0)

func stop_motion():
	set(str("parameters/",current_state.capitalize(),"/blend_position"),-1)

func disarm():
	set("parameters/IsArmed/blend_amount",0)
	is_armed = false

func update_holded(wpntype:String):
	#TODO: set values con un tween o buscar tutorial para hacerlo de otra forma
	match wpntype:
		"handgun":
			set("parameters/Hold/blend_position",0)
		"lmg":
			set("parameters/Hold/blend_position",1)
	
	if !is_armed:
		set("parameters/IsArmed/blend_amount",1)
		is_armed = true
