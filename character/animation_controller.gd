class_name AnimationController extends AnimationTree

enum MotionState { DOWNED = -1, NORMAL, CROUCH, INJURED }
var motion_state = MotionState.NORMAL:
	set(value):
		motion_state = value
		var blend_pos = get("parameters/state/blend_position")
		blend_pos.y = motion_state
		set_motion_state(blend_pos)

var is_armed_path := "parameters/IsArmed/blend_amount"
var equipped_type := {
	'blend_amount':0,
	'param':"melee",
	'blend_pos':Vector2i()
}

func move(run:bool = false): set_motion_state(Vector2(1 if !run else 2, motion_state))

func stop(): set_motion_state(Vector2(0, motion_state))


func update_equipped(_wpn):
	if !_wpn: return
	
	equipped_type.blend_amount = 0 if _wpn is MeleeWeapon else 1
	equipped_type.param = "melee" if _wpn is MeleeWeapon else "ranged"
	equipped_type.blend_pos.x = _wpn.type
	
	set("parameters/wpn_type/blend_amount",equipped_type.blend_amount)
	set(str("parameters/",equipped_type.param,"/blend_position"),equipped_type.blend_pos)
	set(is_armed_path, 1)


func disarm(): set(is_armed_path, 0)


func aim(_aim:bool):
	var _current_pos:Vector2 = get(str("parameters/",equipped_type.param,"/blend_position"))
	_current_pos.y = 0 if !_aim else 1
	set(str("parameters/",equipped_type.param,"/blend_position"), _current_pos)


func reload_gun():
	print(" RELOADING...")


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
