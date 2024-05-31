extends Action


func init():
	pass

func update():
	range_ = actor.equipped_wpn.range_

func execute():
	#var dmg = actor.equipped_weaponsmg, actor)
	
	actor.attack(actor.target_unit)
