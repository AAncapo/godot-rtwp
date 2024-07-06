extends Action


func init():
	if actor.equipment.equipped_wpn.weapon_class == Weapon.WeaponClass.RANGED:
		count = actor.equipment.equipped_wpn.current_clip


func select():
	var equipped_wpn = actor.equipment.equipped_wpn
	if (equipped_wpn is RangedWeapon 
	and !equipped_wpn.clip_updated.is_connected(update_count)):
		equipped_wpn.clip_updated.connect(update_count)
	super.select()


func execute():
	actor.attack(actor.target_unit)
	if actor.equipment.equipped_wpn.weapon_class == Weapon.WeaponClass.UNARMED:
		actor.anim.request_equipped_oneshot()
	super.execute()
