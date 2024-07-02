class_name Attack extends Node

var actor
var target
var wpn
var damage:int


func _init(_actor, _target) -> void:
	actor = _actor
	target = _target
	wpn = actor.equipment.equipped_wpn
	damage = wpn.damage


func calc_hit_chance():
	var attacker_roll
	var defender_roll
	
	var wpn_skill = 0 if !actor.stats.skills.has(wpn.related_skill) else actor.stats.skills[wpn.related_skill]
	if wpn is RangedWeapon:
		#TODO meter esto en el script de weapon y cambiar el return nose. la cosa es q si wpn.shoot returns false (xq esta reloading x ejemplo) attacker/defender_roll va a devolver null
		if wpn.shoot():  #play atk animation & sfx & projectile...
			attacker_roll = actor.stats.REF + wpn_skill + Fnff.roll(1,10)
			defender_roll = Fnff.get_ranged_hit_dv(wpn.range_, actor.global_position, target.global_position)
	else:
		#TODO melee relevant skills
		attacker_roll = actor.stats.DEX + wpn_skill + Fnff.roll(1,10)
		defender_roll = target.stats.DEX + target.stats.skills.evasion + Fnff.roll(1,10)
	
	return attacker_roll > defender_roll
