extends Action


func init():
	if actor.equipment.equipped_wpn.weapon_class == Weapon.WeaponClass.RANGED:
		if actor.equipment.equipped_wpn.ammo:
			count = actor.equipment.equipped_wpn.ammo.current_amount


func select():
	var equipped_wpn = actor.equipment.equipped_wpn
	if (equipped_wpn is RangedWeapon 
	and !equipped_wpn.clip_updated.is_connected(update_count)):
		equipped_wpn.clip_updated.connect(update_count)
	super.select()


func execute():
	#TODO (?) get targets in crosshair line and get the hit chance for each one
		#that way emulate firendly fire or lost bullets hits
	var atk = Attack.new(actor, actor.target_unit)
	var hit = atk.calc_hit_chance()
	if hit: 
		#TODO wait till bullet hits or melee animation finishes
		#this must be on the bullet (when reaches or exceded target pos > deal damage)
		actor.target_unit.take_damage(atk) 
	#else: msg(Global.POPUP_NOTIF.NORMAL,"Miss")
	
	if actor.equipment.equipped_wpn.weapon_class == Weapon.WeaponClass.UNARMED:
		actor.anim.request_equipped_oneshot()
	super.execute()
