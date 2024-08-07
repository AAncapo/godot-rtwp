class_name Stats extends Node

signal updated

##Use this enum from any script as indexed reference to all the BoneAttachment nodes in the model linked to body parts that can use equipment, be affected by damage or replaced
enum BL { Head, Torso, ShoulderR, LowerarmR, HandR, ThighR, ShinR, ShoulderL, LowerarmL, HandL, ThighL, ShinL }
#Note: CPRED doesnt have any table for hit locations and the one in CP2020 doesnt have the amount I need
var BODY_TABLE = {
	"Head"  : { "to_hit_nums":[1],     "body_locations":[0] },
	"Torso" : { "to_hit_nums":[2,3,4], "body_locations":[1] },
	"ArmR"  : { "to_hit_nums":[5],     "body_locations":[2,3,4] }, #shoulder-lowerarm-hand
	"ArmL"  : { "to_hit_nums":[6],     "body_locations":[5,6,7] },
	"LegR"  : { "to_hit_nums":[7,8],   "body_locations":[8,9] },  #thigh-shin
	"LegL"  : { "to_hit_nums":[9,10],  "body_locations":[10,11] }
	}
#How this works: When getting the hit location first select an 'area' based on 1D6 that matches one of the "to_hit_nums", after that pick a random number from the "body_locations" array to get the body location (the numbers represent the parts that exist in that area from upper to lower)

@export var name_:String
@export var alias:String
@export var portrait_image:Texture2D
@export_node_path("CharacterEquipment") var equipment_node
@onready var equipmt: CharacterEquipment = get_node_or_null(equipment_node)

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
@export var starting_stats := {
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
var current_hp:int:
	set(value):
		current_hp = clamp(value, 0, hitpoints)
		update_wound_state()
var humanity:int
var death_save:int


var skills:Dictionary
@export var visibility_range:float = 10.0
@export var SPEED:float = 5.0

enum WoundedState { ANY, LIGHT, SERIOUS, MORTAL }
var wounded_state:WoundedState
var stabilization_dv:int
var death_save_penalty := 0 
var action_penalty := 0
var at_death_door := false
var is_dead := false:
	set(value):
		is_dead = value
		updated.emit()
var stat_modifiers := []
var total_hits := 0


func _ready() -> void:
	########## Stats ##########
	for s in starting_stats.keys():
		if starting_stats[s] > 0:
			set(s, starting_stats[s])
			continue
		var _pts = max(2, Fnff.roll(1,10))
		set(s,_pts)
		starting_stats[s] = _pts
	
	hitpoints = roundi(10 + (((BODY + WILL)/2) * 5))
	current_hp = hitpoints
	humanity = EMP * 10
	death_save = BODY
	
	########## Skills ##########
	var pts = 86
	for s in Fnff.skills:
		for _s in Fnff.skills.get(s):
			skills[_s] = 2
			pts -= 2
	while pts > 0:
		pts -= 1
		skills[skills.keys().pick_random()] += 1


func calc_damage(atk:Attack) -> Dictionary:
	var damage_status = { text="",amount=0}
	var dmg = atk.damage
	
	##get hit location
	var hit_loc:int = Fnff.roll(1,10)
	for area in BODY_TABLE.keys():
		for num in BODY_TABLE[area].to_hit_nums:
			if hit_loc == num:
				var bl: int = BODY_TABLE[area].body_locations.pick_random()
				#find bl in equipment
				var equipped_gear = equipmt.equipped_gear[BL.keys()[bl]]
				print(name_," was hit in ", BL.keys()[bl])
				if equipped_gear:
					dmg = max(0, dmg - equipped_gear.sp)
					if dmg > 0: #following CP2020s rule
						equipped_gear.sp -= 1
					#print(name_," gear absorbed ",equipped_gear.sp," of the damage")
				#double damage if hit HEAD
				if dmg > 0 and BL.keys()[bl] == "Head":
					dmg *= 2
				print(name_," take ",dmg," damage")
				current_hp -= dmg
				
				if dmg > 0:
					total_hits += 1
					print(name_, " total hits: ",total_hits)
	
	damage_status.amount = dmg
	return damage_status


func update_wound_state():
	#mortally wounded
	if current_hp <= 1 and !is_dead:
		wounded_state = WoundedState.MORTAL
		if !at_death_door:
			at_death_door = true
			roll_death_save()
	if current_hp <= hitpoints / 2: wounded_state = WoundedState.SERIOUS
	if current_hp != hitpoints: wounded_state = WoundedState.LIGHT
	wounded_state = WoundedState.ANY
	update()


func update():
	if !equipmt: 
		printerr("An Equipment Node needs to be assigned to Stats.equipment_node")
		return
	
	#Reset all stats
	stat_modifiers = []
	for s in starting_stats:
		self.set(s,starting_stats[s])
	
	## Armor Penalties (CPRED Corebook pg.96)
	#Wearing even a single piece of heavier armor will lower your REF, DEX, and MOVE by the most punishing Armor Penalty of armor you are wearing. You take this penalty only once even though you are likely wearing armor on both your body and head. This penalty can even leave your Character (at a minimum of MOVE 0) completely immobile
	var hpa  #heaviest penalty armor
	for key in equipmt.equipped_gear:
		if equipmt.equipped_gear[key] != null:
			var equipped = equipmt.equipped_gear[key] as Gear
			if !hpa: hpa = equipped
			if equipped.penalty > hpa.penalty:
				hpa = equipped
	if hpa:
		var penal = -hpa.penalty
		var armor = { hpa.name_: { "REF":penal, "DEX":penal, "MOVE":penal }}
		stat_modifiers.append(armor)
	
	var wound := {}
	match wounded_state:
		WoundedState.ANY:
			wound = {"wounded_state": { "stabilization_dv": 0 }}
		WoundedState.LIGHT:
			wound = {"wounded_state": { "stabilization_dv": 10 }}
		WoundedState.SERIOUS:
			wound = {"wounded_state": { "stabilization_dv": 13, "action_penalty":+2 }}
		WoundedState.MORTAL:
			wound = {"wounded_state": { "stabilization_dv": 15, "action_penalty": +4, "MOVE":-6 }}
	stat_modifiers.append(wound)
	
	for mod in stat_modifiers:
		for s in mod[mod.keys()[0]]:
			var stat = get(s)
			set(s, stat + mod[mod.keys()[0]][s])
	
	updated.emit()


func get_stat_mods(stat:String):  #used by inventoryUi
	return get(stat) - starting_stats[stat]


func roll_death_save():
	var res = Fnff.roll(1,10,death_save_penalty)
	if res > death_save:
		Global.unit_died.emit(owner)
	else:
		death_save_penalty += 1
		owner.end_turn()
	
	updated.emit()
