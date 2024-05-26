extends Node3D

var routes:Dictionary

func _ready() -> void:
	for r in get_children():
		routes[r.name] = {
			"path" : r.get_children()
		}
