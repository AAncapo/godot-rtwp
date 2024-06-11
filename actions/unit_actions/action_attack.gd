extends Action


func init():
	count = actor.equipped_wpn.current_clip


func select():
	if (actor.equipped_wpn is RangedWeapon 
	and !actor.equipped_wpn.clip_updated.is_connected(update_count)):
		actor.equipped_wpn.clip_updated.connect(update_count)
	super.select()


func execute():
	actor.attack(actor.target_unit)
	super.execute()
