extends Node

enum { STUN_SAVE, DEATH_SAVE }


func roll(amount:int, sides:int):
	var res := 0
	for a in range (amount):
		res += randi_range(1,sides)
	return res


func save_roll(stats:Stats, save:int):
	var penalty_modif
	match save:
		Fnff.DEATH_SAVE:
			penalty_modif = stats.death_penal_modf
		Fnff.STUN_SAVE:
			penalty_modif = stats.stun_penal_modf
	var toSave_num = max(stats.BODY - penalty_modif, 1)
	
	return roll(1,10) <= toSave_num ##CP2020: roll must be <= the result to SUCCEED
