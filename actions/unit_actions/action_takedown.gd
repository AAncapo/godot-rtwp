extends Action

func execute():
	if !actor.stealth_on: #the action button should be already disabled if !stealth
		return
	
	actor.choke()
	actor.target_unit.get_choked(true)
	
	super.execute()
