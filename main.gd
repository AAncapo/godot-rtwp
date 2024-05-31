extends Node3D


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused


func _ready() -> void:
	randomize()
	create_stats()


func create_stats():
	var units = get_tree().get_nodes_in_group(Global.UNIT_GROUP)
	for u in units:
		var pts := 40
		var s = []
		var stats = {
			intl=0,
			ref=0,
			cl=0,
			tch=0,
			lk=0,
			att=0,
			ma=0,
			emp=0,
			bod=0
			}
		
		while pts > 0:
			var r_index = randi_range(0,stats.size()-1)
			if stats.keys()[r_index] == "bod" and stats[stats.keys()[r_index]] >= 4:
				continue
			pts -= 1
			stats[stats.keys()[r_index]] += 1
		
		u.stats.gen_stats(
			stats.intl,
			stats.ref,
			stats.cl,
			stats.tch,
			stats.lk,
			stats.att,
			stats.ma,
			stats.emp,
			stats.bod
			)
