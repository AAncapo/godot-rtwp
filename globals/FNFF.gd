extends Node
## Cyberpunk RED rules ##
#Ranged Combat is resolved:
#Attacker's REF + Relevant Weapon Skill + 1d10
#vs.
#Defender's DV Determined by Range to Target and Weapon OR Defender's DEX + Evasion Skill + 1d10*
#*A Defender with a REF 8 or higher can choose to attempt to dodge a Ranged Attack instead of using the range table to determine the DV

#Melee Combat is resolved:
#Attacker's DEX + Relevant Melee Attack Skill + 1d10
#vs.
#Defender's DEX + Evasion Skill + 1d10

#If you beat the DV (Defender wins in a tie) you damage the Defender.


func roll(amount:int, sides:int, mod:int = 0):
	var res := 0
	for a in range (amount):
		res += randi_range(1,sides)
	return res + mod


func get_ranged_hit_dv(wpn_range:float, actor_pos:Vector3, target_pos:Vector3):
	#TODO change to CP-RED
	var to_hit := 0
	var dist = (actor_pos - target_pos).length()
	
	var distance = [
		dist > wpn_range * 2, #Extreme
		dist > wpn_range, #Long
		dist > wpn_range * .5, #Medium
		dist > wpn_range * .25, #Close
		true #Point Blank (touching)
		]
	var nums = [30,25,20,15,10]
	for d in distance:
		if d:
			to_hit = nums[distance.find(d)]
			break
	
	return to_hit


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
