extends Node

signal command(target)
signal added_unit(unit)
signal unit_died(unit)

## SHOULD only be emitted by nodes that dont handle selection
#portraits listen to the signals then call de sel/deselect_unit funcs
signal unit_selected(unit:Unit)
signal unit_deselected(unit:Unit)
signal unit_focused(position:Vector3)
signal dialog_triggered(key:String)
signal close_dialog

const UNIT_GROUP = "units"
const ITEM_GROUP = "items"
const PLAYER_TEAM = 0
const ENEMY_TEAM = 1
var player_team_color = Color("265cffc8")
var hostile_team_color = Color("ff2626c8")
const POPUP_NOTIF = {
	NORMAL     = { text="", fsize=10, fcolor=Color.WHITE_SMOKE, auto_fade=true },
	DEATH_DOOR = { text="DEATH DOOR", fsize=15, fcolor=Color.RED, auto_fade=false },
	STUN       = { text="STUN", fsize=15, fcolor=Color.DARK_GRAY, auto_fade=false },
	}
var player_units:Array = []
var enemy_units:Array = []
var selected_units = []
#var player_leader:
	#set(value):
		#player_leader=value
		#if player_leader:
			#for u in player_units:
				#u.is_leader = u == player_leader
			#print("new player lead: ", player_leader.stats.alias)


func add_unit(unit):
	match unit.team:
		PLAYER_TEAM: Global.player_units.append(unit)
		ENEMY_TEAM: Global.enemy_units.append(unit)
	added_unit.emit(unit)


func select_unit(unit):
	if !selected_units.has(unit):
		selected_units.append(unit)
		unit.is_selected = true
		
		#player_leader = unit


func deselect_unit(unit):
	if selected_units.has(unit):
		selected_units.remove_at(selected_units.find(unit))
		unit.is_selected = false
		
		#if player_leader == unit:
			#player_leader = null
			#for u in selected_units:
				#player_leader=u
				#break


func deselect_all_units():
	var _selected_units = selected_units.duplicate()
	for u in _selected_units:
		unit_deselected.emit(u)


func _on_interactable_selected(interactabl):
	var unit:Character
	for u in selected_units:
		if !unit: unit = u
		if (u.global_position.distance_to(interactabl.global_position) 
		< unit.global_position.distance_to(interactabl.global_position)):
			unit = u
	unit.target_interaction = interactabl
