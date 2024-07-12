extends Node


func roll(amount:int, sides:int, mod:int = 0):
	randomize()
	var res := 0
	for a in range (amount):
		res += randi_range(1, sides)
	return res + mod


var skills := {
	#skillbase   #skills
	"INT"       :[ "conceal_reveal", "perception", "deduction" ],
	"WILL"      :[ "concentration", "endurance" ],
	"DEX"       :[ "athletics", "stealth", "brawling", "evasion", "melee_weapons" ],
	"REF"       :[ "autofire", "handguns", "heavy_weapons", "shoulder_arms", "archery" ],
	"COOL"      :[ "persuasion", "interrogation", "acting" ],
	"TECH"      :[ "first_aid", "basic_tech", "cybertech", "paramedic", "weaponstech" ]
	}
#Skills are normally rated from 1 to 10, and are used in gameplay by adding the Level of the Skill to the Level of the most applicable Statistic. Skills are like STATs; they have a range of effectiveness that is related to how much they cost
