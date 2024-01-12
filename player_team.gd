extends Node

signal player_team_initialized
signal added_player(unit)
signal removed_player(unit)

const TEAM:int = 0
const MAX_PLAYERS:int = 4

@export_range(1, MAX_PLAYERS) var team_size = 1
@onready var players = $Players
@onready var formations = $Formations
var target_unit:Unit
var team:Array[Character]
var curr_formation = 0  #index in $Formations/f?

#### PLACEHOLDERS ####
@export var ph_portraits: Array[CompressedTexture2D]
var player_tscn = preload("res://characters/player.tscn")
######################


func _ready():
	GameEvents.character_died.connect(remove_player)
	GameEvents.form_selected.connect(on_formation_selected)
	spawn_players()
	player_team_initialized.emit()


func spawn_players():
	for p in range(team_size):
		var player: Character = player_tscn.instantiate()
		## Placeholder ##
		if ph_portraits[p]:
			player.portrait_texture = ph_portraits[p]
		## Create save system for storing the last position
		team.append(player)
		players.add_child(player)
		player.name = str("player ",players.get_child_count())
		player.global_position = get_formation_positions()[p]
		added_player.emit(player)


func set_form_position(desired_pos: Vector3):
	var dir = (desired_pos - formations.global_position).normalized()
	formations.look_at(dir, Vector3.UP)
	formations.global_position = desired_pos


func get_formation_positions() -> Array:
	var form_positions = []
	var form = formations.get_child(curr_formation).get_children()
	for pos in range(form.size()):
		form_positions.append(form[pos].global_position)
	return form_positions


func on_formation_selected(formation):
	curr_formation = formation


func update_target(new_target):
	if target_unit != null:
		target_unit.deselect_as_target.emit()
	target_unit = new_target
	target_unit.select_as_target.emit()


func remove_player(unit):
	if team.has(unit):
		team.remove_at(team.find(unit))
		removed_player.emit(unit)


func _on_selection_sys_command_units(selected_units:Array, target_obj:Dictionary):
	if selected_units.is_empty():
		return
	for u in selected_units:
		u.updated_manually = true
	
	#if the target is a unit the players move freely towards it.
	if target_obj.collider.is_in_group('units'):
		update_target(target_obj.collider)
		for u in selected_units:
			u.set_target(target_obj.collider)
			#after this the charAI decides what to do with the collider info
	elif (target_obj.collider.is_in_group('cover')):
		for u in selected_units:
			u.set_target(target_obj.collider)
			break  #only the first unit on the list get the cover
			#TODO: make the remaining selected units find a cover nearby
	else:
		if selected_units.size() > 1:
			set_form_position(target_obj.position)
			var index = 0
			for u in selected_units:
				u.set_target(get_formation_positions()[index])
				index += 1
		else:
			if selected_units[0].team == TEAM:
				selected_units[0].set_target(target_obj.position)
