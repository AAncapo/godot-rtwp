extends Node

func init(_actor):
	for a in get_children():
		a.actor = _actor
		a.selected.connect(_actor._on_action_selected)


func get_action(_action_id:String):
	var _id := _action_id.to_lower()
	for a in get_children():
		if a.name.to_lower()==_id:
			return a
