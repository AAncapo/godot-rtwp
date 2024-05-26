extends Action

var selected_option = "lethal"

func init():
	pass

func update():
	pass

func execute():
	if actor.current_state != actor.STEALTH:
		#the action button should be already disabled if !stealth
		return
	
	match selected_option:
		"non-lethal":
			actor.choke()
			actor.target_unit.set_unconsious()
		"lethal":
			actor.choke()
			actor.target_unit.get_choked(true)
	
	#super.execute() 
