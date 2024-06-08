extends Action
## Call the reload_gun() in the actor.anim
## Get the anim_finished signal at self._on_anim_finished()
## Execute the action


func select():
	if !actor.anim.animation_finished.is_connected(_on_anim_finished):
		actor.anim.animation_finished.connect(_on_anim_finished)
	actor.anim.reload_gun()
	super.select()
	
	##placeholder TODO create animation
	await get_tree().create_timer(1.0)
	execute()


func _on_anim_finished(anim:String):
	execute()


func execute():
	#print("RELOADED")
	actor.equipped_wpn.reload()
	actor.end_turn()
	super.execute()
	actor.actions.get_action('attack').select()
