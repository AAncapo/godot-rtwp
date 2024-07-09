class_name Attack extends Resource

var actor:Character
var target:Character
var wpn:Weapon
var damage:int


func _init(_actor, _target) -> void:
	actor = _actor
	target = _target
	wpn = actor.equipment.equipped_wpn
	damage = wpn.damage


func calc_hit_chance():
	var attacker_roll:int
	var defender_roll:int
	
	var wpn_skill = 0 if !actor.stats.skills.has(wpn.related_skill) else actor.stats.skills[wpn.related_skill]
	match wpn.weapon_class:
		#Ranged Combat is resolved:
		#Attacker's REF + Relevant Weapon Skill + 1d10 vs. Defender's DV Determined by Range to Target and Weapon OR Defender's DEX + Evasion Skill + 1d10*
		Weapon.WeaponClass.RANGED:
			if !wpn.attack():
				return
			
			var DV = Fnff.get_range_dv(wpn, actor.global_position, target.global_position)
			if DV < 0:  #get_range_dv() returns -1 if out of range
				return 0
			attacker_roll = actor.stats.REF + wpn_skill + Fnff.roll(1,10)
			defender_roll = DV
			#TODO *A Defender with a REF 8 or higher can choose to attempt to dodge a Ranged Attack instead of using the range table to determine the DV
		
		#Melee Combat is resolved:
		#Attacker's DEX + Relevant Melee Attack Skill + 1d10 vs. Defender's DEX + Evasion Skill + 1d10
		Weapon.WeaponClass.MELEE, Weapon.WeaponClass.UNARMED:
			attacker_roll = actor.stats.DEX + wpn_skill + Fnff.roll(1,10)
			defender_roll = target.stats.DEX + target.stats.skills.evasion + Fnff.roll(1,10)
	
	#If you beat the DV (Defender wins in a tie) you damage the Defender.
	return attacker_roll > defender_roll
