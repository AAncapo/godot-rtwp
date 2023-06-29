extends Node3D

@onready var selindicator = $SelectionIndicator
var sel_material
@onready var _char: Character = owner

func _ready():
	selindicator.hide()
	$char_name.text = owner.name
	set_sel_material()
	$HealthBar.get_surface_override_material(0).set_shader_parameter("progress", _char.current_health/10)


func set_sel_material():
	match  owner.team:
		0:
			sel_material = load("res://materials/chars/team0selected-material.tres")
		1:
			sel_material = load("res://materials/chars/team1selected-material.tres")
		2:
			sel_material = load("res://materials/chars/team2selected-material.tres")
	selindicator.set("surface_material_override/0", sel_material)


func _on_character_selected():
	$AnimationPlayer.play("character animations/show_selection")

func _on_character_deselected():
	$target_pos.hide()
	selindicator.hide()

func _on_character_select_as_target():
	_on_character_selected()

func _on_character_deselect_as_target():
	_on_character_deselected()


func _on_character_damaged():
	$HealthBar.get_surface_override_material(0).set_shader_parameter("progress", _char.current_health/10)
	pass
