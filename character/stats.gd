class_name Stats extends Node

signal new_wound_state(stat)

enum BL { Any, Head, Torso, ShoulderR, ShoulderL, LowerarmR, LowerarmL, HandR, HandL }

@export var name_:String
@export var alias:String
@export var portrait_image:Texture2D

var INT  :int
var WILL :int
var EMP  :int
var COOL :int
var REF  :int
var LUCK :int
var DEX  :int
var TECH :int
var MOVE :int
var BODY :int
var starting_stats = {
	"INT"  : 0,
	"WILL" : 0,
	"EMP"  : 0,
	"COOL" : 0,
	"REF"  : 0,
	"LUCK" : 0,
	"DEX"  : 0,
	"TECH" : 0,
	"MOVE" : 0,
	"BODY" : 0
	}
var hitpoints:int
var humanity:int
var death_save:int

var current_hp:int:
	set(value):
		current_hp = clamp(value, 0, hitpoints)
		_update_wound_state()
		#print(name_, " HP: ",current_hp)

var skills:Dictionary
@export var visibility_range:float = 10.0

@export var SPEED:float = 5.0

var current_wound_state:String:
	set(value):
		current_wound_state = value
		new_wound_state.emit(self)
var stabilization_dv:int
var death_save_penalty := 0 
var action_penalty := 0
var at_death_door := false
var is_dead := false

var total_dmg := 0


func _init():
	## Stats
	for s in starting_stats.keys():
		var _pts = Fnff.roll(1,10)
		self[s] = _pts
		starting_stats[s] = _pts
	
	hitpoints = roundi(10 + (((BODY + WILL)/2) * 5))
	current_hp = hitpoints
	humanity = EMP * 10
	death_save = BODY
	
	## Skills
	var pts = 86
	#get skills from db
	for s in Fnff.skills:
		for _s in Fnff.skills.get(s):
			skills[_s] = 2
			pts -= 2
	while pts > 0:
		pts -= 1
		skills[skills.keys().pick_random()] += 1
	#print(name_," skills: ",skills)


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
	
	current_hp -= dmg
	
	total_dmg += dmg
	
	damage_status.amount = dmg
	return damage_status


func _update_wound_state():
	#mortally wounded
	if current_hp <= 1 and !is_dead: 
		action_penalty = 4
		stabilization_dv = 15
		if !at_death_door:
			at_death_door = true
			roll_death_save()
			#TODO get back to prev value when out of wound state
			MOVE = max(MOVE - 6, 1)
			return
	#seriously wounded
	if current_hp <= hitpoints / 2: 
		action_penalty = 2
		stabilization_dv = 13
		return
	#lightly wounded
	if current_hp != hitpoints: 
		action_penalty = 0
		stabilization_dv = 10
		return


func roll_death_save():
	var res = Fnff.roll(1,10,death_save_penalty)
	if res > death_save:
		Global.unit_died.emit(owner)
	else:
		death_save_penalty += 1
		owner.end_turn()


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
