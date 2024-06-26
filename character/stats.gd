class_name Stats extends Node

signal new_wound_state(stat)

const BODY_TYPES := {
	#TYPE         :BTM  
	"VERY_WEAK"   : 0, 
	"WEAK"        : 1, 
	"AVERAGE"     : 2, 
	"STRONG"      : 3,
	"VERY_STRONG" : 4,
	"SUPERMAN"    : 5
	}
const WOUND_STATES := {
	#state:   stun/death (modf)
	"LIGHT":    [0,0],
	"SERIOUS":  [1,0],
	"CRITICAL": [2,0],
	"MORTAL":   [3,0],
	"MORTAL1":  [4,1],
	"MORTAL2":  [5,2],
	"MORTAL3":  [6,3],
	"MORTAL4":  [7,4],
	"MORTAL5":  [8,5],
	"MORTAL6":  [9,6],
	}

@export var name_:String
@export var alias:String
@export var portrait_image:Texture2D

@export var INTEL:int
@export var REFLEX:int
@export var COOL:int
@export var TECH:int
@export var LUCK:int
@export var ATTRACT:int
@export var MOV_ALLOW:int
@export var EMPATHY:int
@export var BODY:int:
	set(value):
		BODY = value
		var idx
		match value:
			0,1,2: idx=0
			3,4  : idx=1
			5,6,7: idx=2
			8,9  : idx=3
			_    : idx=4
		body_type = BODY_TYPES.keys()[idx]
		btm = BODY_TYPES[body_type]

@export var visibility_range:float = 10.0

@export var SPEED:float = 10.0:
	get:
		walk_speed = SPEED * .2
		crouch_speed = SPEED * .2
		run_speed = SPEED
		var _speed = walk_speed
		var motion_state = owner.anim.motion_state
		match motion_state:
			AnimationController.MotionState.NORMAL:
				_speed = run_speed if owner.is_running else walk_speed
			AnimationController.MotionState.CROUCH:
				_speed = crouch_speed
		return _speed
@export var walk_speed:float
var run_speed:float
var crouch_speed:float

@export var skills = {}

var body_type:String #BODY_TYPE key
var btm:int  #BODTYP MODIFIER: subtract from any damage taken
var damage_modifier:int = 0: #add to MELEE attacks damage
	get:
		var dmg_mod:int
		match body_type:
			"VERY_WEAK"   : dmg_mod = -2
			"WEAK"        : dmg_mod = -1
			"AVERAGE"     : dmg_mod = 0 
			"STRONG"      : dmg_mod = 1
			"VERY_STRONG" : dmg_mod = 2
			"SUPERMAN"    :
				match BODY:
					11,12: dmg_mod = 4
					13,14: dmg_mod = 6
					_: dmg_mod = 8
		return dmg_mod
var current_wound_state:String:  #WOUND_STATE key
	set(value):
		current_wound_state = value
		new_wound_state.emit(self)
var ws_lvl := 0:  #WS levels go from 1-4, update state at 5
	set(value):
		ws_lvl = value
		
		if current_wound_state.is_empty():
			current_wound_state = WOUND_STATES.keys()[0]
			ws_lvl = 1
		
		var next_ws = (WOUND_STATES.keys()).find(current_wound_state) + 1
		if ws_lvl > 4 and next_ws < WOUND_STATES.size():
			ws_lvl = 1
			current_wound_state = WOUND_STATES.keys()[next_ws]
		
		stun_penal_modf = WOUND_STATES[current_wound_state][0]
		death_penal_modf = WOUND_STATES[current_wound_state][1]

var death_penal_modf := 0 
var stun_penal_modf := 0

var at_death_door := false:  #true if death saves are required
	set(value):
		at_death_door = value
		if at_death_door: 
			owner.msg(Global.POPUP_NOTIF.DEATH_DOOR)
			owner.current_state = owner.State.DOWNED
var is_stunned := false:
	set(value):
		is_stunned=value
		if is_stunned: 
			owner.msg(Global.POPUP_NOTIF.STUN)
			owner.current_state = owner.State.DOWNED
			owner.end_turn()
		else:
			owner.msg(Global.POPUP_NOTIF.STUN,'',true)
var is_dead := false

var total_dmg := 0


func calc_damage(atk:Attack) -> Dictionary:
	var damage_status = { text="",amount=0}
	var dmg = atk.damage
	
	##get hit location
	var hit_loc:int = Fnff.roll(1,10)
	for bp in BODY_PARTS:
		if (bp.location_id).has(hit_loc):
			#TODO: substract the sp of the body part to the dmg
			damage_status.text = bp.label
			#double damage if hit HEAD
			if bp.label == "HEAD":
				damage_status.text = "HEADSHOT"
				dmg *= 2
	
	dmg -= btm  ##substract BTM
	total_dmg += dmg
	for _pts in range(dmg):  ##update wounded state
		ws_lvl += 1
	
	#make death/stun save roll
	at_death_door = death_penal_modf > 0
	if at_death_door: 
		if !Fnff.save_roll(self, Fnff.DEATH_SAVE):
			Global.unit_died.emit(owner)
			damage_status.amount = dmg
			return damage_status
	
	if stun_penal_modf > 0 and !is_stunned: 
		is_stunned = !Fnff.save_roll(self, Fnff.STUN_SAVE)
	
	damage_status.amount = dmg
	return damage_status


func gen_stats(intl,ref,cl,tch,lk,att,ma,emp,bod) -> void:
	INTEL = intl
	REFLEX = ref
	COOL = cl
	TECH = tch
	LUCK = lk
	ATTRACT = att
	MOV_ALLOW = ma
	EMPATHY = emp
	BODY = bod

func get_stats_dictionary():
	return {
		"INTEL" : INTEL,
		"REFLEX" : REFLEX,
		"COOL" : COOL,
		"TECH" : TECH,
		"LUCK" : LUCK,
		"ATTRACT" : ATTRACT,
		"MOV_ALLOW" : MOV_ALLOW,
		"EMPATHY" : EMPATHY,
		"BODY" : BODY
		}

var BODY_PARTS = [
	BodyPart.new("HEAD",[1]),
	BodyPart.new("TORSO", [2,3,4]),
	BodyPart.new("RIGHT_ARM", [5]),
	BodyPart.new("LEFT_ARM", [6]),
	BodyPart.new("RIGHT_LEG", [7,8]),
	BodyPart.new("LEFT_LEG", [9,10])
	]


class BodyPart:
	var label:String
	var location_id := []
	var armor_sp
	
	func _init(lbl:String, loc:Array) -> void:
		label = lbl
		location_id = loc
