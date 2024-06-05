extends Action


func execute():
	actor.stealth_on = !actor.stealth_on
	
	super.execute()
