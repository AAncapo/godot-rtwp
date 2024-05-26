extends Action

func init():
	actor.current_state = actor.STEALTH if actor.current_state != actor.STEALTH else actor.previous_state
	super.init()

func update():
	pass

func execute():
	pass
