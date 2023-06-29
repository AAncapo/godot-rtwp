extends Control

@onready var char_cards_container = $PlayersControl/VBoxContainer/CharacterCards
@onready var formEditor = $FormationsButton/FormationEditor
var charStatsCard_tscn = preload("res://ui/character_card.tscn")


func _ready():
	GameEvents.ui_toggle_form_tab.connect(on_form_tab_toggle)
	
	var player_team_chars = get_tree().get_nodes_in_group('units')
	if player_team_chars:
		for character in player_team_chars:
			if character.team == 0:
				var char_stats_card = charStatsCard_tscn.instantiate()
				char_cards_container.add_child(char_stats_card)
				char_stats_card.char_owner = character


func _process(_delta):
	$Paused.visible = get_tree().paused
	
	$fps_counter.text = str('fps: ',Engine.get_frames_per_second())


func on_form_tab_toggle():
	formEditor.visible = !formEditor.visible

func _on_formations_button_pressed():
	formEditor.visible = !formEditor.visible
