class_name AnimationController extends AnimationTree

var state:String = "normal":
	set(value):
		var blend:float
		match value:
			"normal": blend = 0
			"alert": blend = 1
			_: blend = get("parameters/State/blend_amount")
		set("parameters/State/blend_amount", blend)
		self.motion_path = value if value=="normal" || value=="alert" || value=="downed" else state
		state = value

var motion_path:String = "parameters/normal/blend_position":
	set(value):
		motion_path = str("parameters/",value,"/blend_position")
var isarmed_path:String = "parameters/IsArmed/blend_amount"
var holdaim_path:String = "parameters/hold_aim/blend_position"
var equipped_class:String
var aim_vec:Vector2i


func move(run:bool = false): set(motion_path, 2 if run else 1)

func stop(): set(motion_path, 0)

func equip(item_class:String):
	equipped_class = item_class
	set(isarmed_path, 1)
	aim(true if aim_vec.y > 0 else false)  #continue aiming

func disarm(): set(isarmed_path, 0)


func aim(aim:bool = false):
	aim_vec = Vector2i(0,0)
	aim_vec.x = 0 if equipped_class == "handgun" else 1
	aim_vec.y = 0 if not aim else 1
	set(holdaim_path, aim_vec)
