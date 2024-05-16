extends Node

const UNIT_GROUP = "units"
const ITEM_GROUP = "items"
const PLAYER_TEAM = 0
const ENEMY_TEAM = 1

var player_units:Array = []
var enemy_units:Array = []
var selected_units = []

signal command(target)
signal gui_select_unit(unit)
signal focus_world_object(object)
signal added_unit(unit)
signal unit_died(unit)
#signal removed_unit(unit)


func add_unit(unit):
	match unit.team:
		PLAYER_TEAM: Global.player_units.append(unit)
		ENEMY_TEAM: Global.enemy_units.append(unit)
	added_unit.emit(unit)


func remove_unit(unit):
	print("Global.remove_unit not implemented yet")
	#removed_unit.emit(unit)
