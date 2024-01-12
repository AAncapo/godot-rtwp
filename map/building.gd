extends Node3D

var cspots = []

func _ready():
	cspots = $cspots.get_children()
