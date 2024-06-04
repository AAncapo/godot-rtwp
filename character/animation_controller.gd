class_name AnimationController extends AnimationTree

enum MotionState { DOWNED = -1, NORMAL, CROUCH, INJURED }
var motion_state = MotionState.NORMAL:
	set(value):
		match value:
			Character.State.WORKING:
				value = MotionState.NORMAL
		motion_state = value
		var blend_pos = get("parameters/state/blend_position")
		blend_pos.y = motion_state
		set_motion_state(blend_pos)

var is_armed:String = "parameters/IsArmed/blend_amount"
var holdaim_path:String = "parameters/hold_aim/blend_position"
var equipped_type:int
var aim_vec:Vector2i


func move(run:bool = false): set_motion_state(Vector2(1 if !run else 2, motion_state))

func stop(): set_motion_state(Vector2(0, motion_state))


func equip(type:int):
	equipped_type = type
	set(is_armed, 1)
	aim(true if aim_vec.y > 0 else false)  #continue aiming if already


func disarm(): set(is_armed, 0)


func aim(_aim:bool = false):
	aim_vec = Vector2i(0,0)
	aim_vec.x = equipped_type
	aim_vec.y = 0 if not _aim else 1
	set(holdaim_path, aim_vec)


func choke(): request_oneshot(0)

var die_after_choked:bool = false
func get_choked(_die:bool):
	die_after_choked = _die
	request_oneshot(1)

func die(): request_oneshot(-1)


func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"Character4/choked":
			if die_after_choked:
				die()
				return
			printerr("Choked animation finished but no unconscious animation is set")
		
		"Character4/death":
			owner.disable()


func set_motion_state(blend_pos:Vector2):
	set("parameters/state/blend_position",blend_pos)


func request_oneshot(blend_amount:int):
	set("parameters/die_choked_choke/blend_amount",blend_amount)
	set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
