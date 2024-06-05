extends Action


func execute():
	actor.attack(actor.target_unit)
	
	super.execute()
