extends Action
## Call the reload_gun() in the actor.anim
## Get the anim_finished signal at self._on_anim_finished()
## Execute the action


func select():
	if !actor.anim.animation_finished.is_connected(_on_anim_finished):
		actor.anim.animation_finished.connect(_on_anim_finished)
	actor.anim.request_equipped_oneshot()
	super.select()


func _on_anim_finished(_anim:String):
	var ranged_type:String = RangedWeapon.RangedType.keys()[actor.equipment.equipped_wpn.ranged_type]
	
	if _anim == str("reload_", ranged_type.to_lower()):
		execute()


func execute():
	#print("RELOADED")
	actor.equipment.equipped_wpn.reload()
	actor.end_turn()
	super.execute()
	actor.actions.get_action('attack').select()
