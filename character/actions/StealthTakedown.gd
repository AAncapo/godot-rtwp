extends Action

enum TakedownStyle { NON_LETHAL, LETHAL }
var tdstyle = TakedownStyle.NON_LETHAL

func update():
	#update td style
	#use this to update the animation based in what silent weapon the unit has equipped
	pass

func execute():
	print("takedown executed")
	match tdstyle:
		TakedownStyle.NON_LETHAL:
			actor.target_unit.set_unconsious()
		TakedownStyle.LETHAL:
			actor.target_unit.take_damage(actor,actor.target_unit.health)
