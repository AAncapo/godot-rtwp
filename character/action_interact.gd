extends Action

func execute():
	if actor.target_interaction:
		actor.target_interaction.interact()
		actor.target_interaction = null
		super.execute()
