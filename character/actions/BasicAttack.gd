extends Action


func init():
	pass

func update():
	range_ = actor.equipped_weapon.range_

func execute():
	var dmg = actor.equipped_weapon.damage
	print(actor.name," deals ",dmg," to ",actor.target_unit.name)
	actor.target_unit.take_damage(dmg, actor)
