class_name AnimationController extends AnimationTree

var motion_y:int:
	set(val):
		motion_y = val
		var blend_pos = get("parameters/state/blend_position")
		blend_pos.y = motion_y
		set("parameters/state/blend_position",blend_pos)
var is_armed:String = "parameters/IsArmed/blend_amount"
var holdaim_path:String = "parameters/hold_aim/blend_position"
var equipped_type:int
var aim_vec:Vector2i


func move(run:bool = false): 
	set("parameters/state/blend_position",Vector2(1 if !run else 2, motion_y))

func stop(): 
	set("parameters/state/blend_position", Vector2(0, motion_y))

func equip(type:int):
	equipped_type = type
	set(is_armed, 1)
	aim(true if aim_vec.y > 0 else false)  #continue aiming

func disarm(): set(is_armed, 0)


func aim(_aim:bool = false):
	aim_vec = Vector2i(0,0)
	
	aim_vec.x = equipped_type
	aim_vec.y = 0 if not _aim else 1
	set(holdaim_path, aim_vec)
