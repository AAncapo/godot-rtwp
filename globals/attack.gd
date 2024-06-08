class_name Attack extends Node

var actor:Character
var target
var wpn
var damage:float

enum { FAILED, FUMBLED, MISSED, SUCCEED }
var result := Attack.SUCCEED


func _init(_actor, _target) -> void:
	actor = _actor
	target = _target
	wpn = actor.equipped_wpn
	damage = wpn.damage


func calc_hit_chance():
	var to_hit_num := get_toHit_number() #CP2020: result must be higher/equal to hit
	
	## ROLL ##
	var res = Fnff.roll(1,10)
	if res == 1: #CP2020: if 'AUTOMATIC FAILURE' roll 1d10 to see what happens
		get_fumble_result()
		return
	if res == 10: #CP2020: if 'CRITICAL SUCCESS' roll another 1d10 & add to prev roll 
		res += Fnff.roll(1,10)
	
	## APPLY TO HIT MODIFIERS ##
	var hit_modifier := get_hit_modifier()
	
	if wpn is RangedWeapon:
		if wpn.shoot():  #play atk animation & sfx & projectile...
			var reflex = actor.stats.REFLEX
			var wpn_skill = 0
			var roll_to_hit = res + reflex + wpn_skill + wpn.accuracy + hit_modifier
			result = Attack.SUCCEED if roll_to_hit >= to_hit_num else Attack.MISSED
	else:
		printerr("MeleeWeapon attack logic hasnt been implemented")


func get_toHit_number() -> int:
	var to_hit := 0
	var wpn_range = wpn.range_
	var dist = (actor.global_position - target.global_position).length()
	
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


func get_hit_modifier() -> int:
	var hit_modifier := 0
	if !target.is_moving: hit_modifier += 4  #target immobile
	if target.is_moving:  #target mobile
		var m = 0
		if target.stats.REFLEX > 10: m = 3
		if target.stats.REFLEX > 12: m = 4
		if target.stats.REFLEX > 14: m = 5
		hit_modifier -= m
	if target.current_state != Character.State.ALERT: #ambush
		#TODO: cambiar a actor isnt detected
		hit_modifier += 5
	return hit_modifier


func get_fumble_result():
	var fumble = Fnff.roll(1,10)
	result = Attack.FAILED if fumble <= 4 else Attack.FUMBLED
