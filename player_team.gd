extends Node

signal added_player(unit)
signal removed_player(unit)

var player_tscn = preload("res://characters/player.tscn")

@onready var formations = $Formations
@onready var players = $Players
const TEAM = 0
var current_formation = 0 #index in $Formations/f?
@export_range(1,6) var players_in_team = 1
var target_unit:Unit
var team:Array[Character]

#### PLACEHOLDERS ####
@export var ph_portraits: Array[CompressedTexture2D]
######################


func _ready():
	GameEvents.character_died.connect(remove_player)
	GameEvents.form_selected.connect(on_formation_selected)
	spawn_players()


func spawn_players():
	for p in range(players_in_team):
		var player: Character = player_tscn.instantiate()
		## Placeholder ##
		if ph_portraits[p]:
			player.portrait_texture = ph_portraits[p]
		## Create save system for storing the last position
		team.append(player)
		player.global_position = get_formation_positions()[p]
		players.add_child(player)
		added_player.emit(player)


func set_form_position(desired_pos: Vector3):
	var dir = (desired_pos - formations.global_position).normalized()
	formations.look_at(dir, Vector3.UP)
	formations.global_position = desired_pos


func get_formation_positions() -> Array:
	var form_positions = []
	var form = formations.get_child(current_formation).get_children()
	for pos in range(form.size()):
		form_positions.append(form[pos].global_position)
	return form_positions


func on_formation_selected(formation):
	current_formation = formation


func update_target(new_target):
	if target_unit != null:
		target_unit.deselect_as_target.emit()
	target_unit = new_target
	target_unit.select_as_target.emit()


func remove_player(unit):
	if team.has(unit):
		team.remove_at(team.find(unit))
		removed_player.emit(unit)


func _on_selection_sys_command_units(selected_units:Array, target_obj:Dictionary, dbl_clickd:bool):
	if selected_units.is_empty():
		return
	for u in selected_units:
		u.force_to = dbl_clickd
	
	#if the target is a unit the players move freely towards it.
	if target_obj.collider.is_in_group('units'):
		update_target(target_obj.collider)
		for u in selected_units:
			u.target = target_obj.collider
			#after this the charAI decides what to do with the collider info
	else:
		if selected_units.size() > 1:
			set_form_position(target_obj.position)
			var index = 0
			for u in selected_units:
				u.target = get_formation_positions()[index]
				index += 1
		else:
			if selected_units[0].team == TEAM:
				selected_units[0].target = target_obj.position
