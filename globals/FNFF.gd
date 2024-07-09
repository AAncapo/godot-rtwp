extends Node


func roll(amount:int, sides:int, mod:int = 0):
	var res := 0
	for a in range (amount):
		res += randi_range(1, sides)
	return res + mod


func get_range_dv(wpn:RangedWeapon, actor_pos:Vector3, target_pos:Vector3) -> int:
	#returns a DV (difficulty value) based on the distance to target (-1 if out of range)
	
	var dv_table_row:Array = RANGE_BASED_DV[RangedWeapon.RangedType.keys()[wpn.ranged_type]]
	var distance:float = (actor_pos - target_pos).length()
	
	var dist_index:int
	for d in DIST_TABLE as Array:
		if distance in range(d[0], d[1]+1):
			dist_index = d.get_index()
			break
		
	var range_dv: int = dv_table_row[dist_index]
	return range_dv


var skills := {
	#skill base  #skills
	"INT"       :[ "conceal_reveal","perception","deduction" ],
	"WILL"      :[ "concentration","endurance" ],
	"DEX"       :[ "athletics","stealth","brawling","evasion","melee_weapons" ],
	"REF"       :[ "autofire","handguns","heavy_weapons","shoulder_arms","archery" ],
	"COOL"      :[ "persuasion","interrogation","acting" ],
	"TECH"      :[ "first_aid","basic_tech","cybertech","paramedic","weaponstech" ]
	}
#Skills are normally rated from 1 to 10, and are used in gameplay by adding the Level of the Skill to the Level of the most applicable Statistic. Skills are like STATs; they have a range of effectiveness that is related to how much they cost

#TODO: firemode.AUTO DV table (pg.173)

#distances in meters
const DIST_TABLE = [[0,6], [7,12], [13,25], [26,50], [51,100], [101,200], [201,400], [401,800]]
#(!!!) The DV table keys need to match the RangedWeapon.RangedType keys name and order
# -1 means N/A (out of range)
const RANGE_BASED_DV = {
	'HANDGUN'          :[  13,     15,    20,     25,     30,    30,     -1,     -1 ], 
	'SMG'              :[  15,     13,    15,     20,     25,    25,     30,     -1 ], 
	'SHOTGUN'          :[  13,     15,    20,     25,     30,    35,     -1,     -1 ], 
	'ASSAULT_RIFLE'    :[  17,     16,    15,     13,     15,    20,     25,     30 ], 
	'SNIPER_RIFLE'     :[  30,     25,    25,     20,     15,    16,     17,     20 ],
	"BOW"              :[  15,     13,    15,     17,     20,    22,     -1,     -1 ],
	"GRENADE_LAUNCHER" :[  16,     15,    15,     17,     20,    22,     25,     -1 ],
	"ROCKET_LAUNCHER"  :[  17,     16,    15,     15,     20,    20,     25,     30 ]
	}
