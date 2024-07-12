class_name AnimationController extends AnimationTree

enum MotionState { DOWNED = -1, NORMAL, CROUCH, ALERTED, INJURED }
var motion_state = MotionState.NORMAL:
	set(value):
		motion_state = value
		var blend_pos = get("parameters/MotionStates/blend_position")
		blend_pos.x = motion_state
		set_motion_state(blend_pos)

var is_armed_path := "parameters/IsEquipped/blend_amount"
var equipped_data := {
	'blend_amount':0,
	'param':"Melee",
	'blend_pos':Vector2i()
}

func move(_run:bool = false): set_motion_state(Vector2(motion_state,1))

func stop(): set_motion_state(Vector2(motion_state, 0))


func update_equipped(wpn:Weapon):
	equipped_data.blend_amount = wpn.weapon_class -1
	equipped_data.param = Weapon.WeaponClass.keys()[wpn.weapon_class].capitalize()
	var blend_pos_x
	match wpn.weapon_class:
		Weapon.WeaponClass.UNARMED: blend_pos_x = 0
		Weapon.WeaponClass.MELEE: blend_pos_x = wpn.melee_type
		Weapon.WeaponClass.RANGED: blend_pos_x = wpn.ranged_type
	equipped_data.blend_pos.x = blend_pos_x
	
	set("parameters/EquippedType/blend_amount",equipped_data.blend_amount)
	set(str("parameters/",equipped_data.param,"/blend_position"),equipped_data.blend_pos)
	
	#set(is_armed_path, 1)
	#TODO if i set it to 0 when unarmed then i cant use the fist attack anims.
	set(is_armed_path, 1 if wpn.weapon_class != Weapon.WeaponClass.UNARMED else 0)


func aim(_aim:bool):
	var _current_pos:Vector2 = get(str("parameters/",equipped_data.param,"/blend_position"))
	_current_pos.y = 0 if !_aim else 1
	set(str("parameters/",equipped_data.param,"/blend_position"), _current_pos)


func choke(): request_oneshot(-1)

var die_after_choked:bool = false
func get_choked(_die:bool):
	die_after_choked = _die
	request_oneshot(0)

func die(): request_oneshot(1)


func _on_animation_finished(anim_name: StringName) -> void:
	match anim_name:
		"grabbed":
			if die_after_choked:
				die()
				return
			printerr("Choked animation finished but no unconscious animation is set")
		
		"die1":
			owner.process_mode = Node.PROCESS_MODE_DISABLED


func set_motion_state(blend_pos:Vector2):
	set("parameters/MotionStates/blend_position",blend_pos)


func request_equipped_oneshot():
	set(str("parameters/", equipped_data.param, "OneshotLink/request"), AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func request_oneshot(blend_amount:int):
	set("parameters/GeneralOneshot/blend_amount",blend_amount)
	set("parameters/GeneralOneshotLink/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
