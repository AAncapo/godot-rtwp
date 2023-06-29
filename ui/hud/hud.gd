extends Control
class_name HUD

@onready var char_cards = $PlayersControl/VBoxContainer/CharacterCards.get_children()
@onready var formEditor = $FormationsButton/FormationEditor


func _ready():
	GameEvents.ui_toggle_form_tab.connect(on_form_tab_toggle)


func _process(_delta):
	$Paused.visible = get_tree().paused
	$fps_counter.text = str('fps: ',Engine.get_frames_per_second())


func on_form_tab_toggle():
	formEditor.visible = !formEditor.visible

func _on_formations_button_pressed():
	formEditor.visible = !formEditor.visible


func _on_player_team_added_player(unit):
	#add reference to character cards
	for card in char_cards:
		if card._char == null:
			card._char = unit
			break


func _on_player_team_removed_player(unit):
	#TODO: dile a character cards q borre esa referencia
	for card in char_cards:
		if card._char == unit:
			card._char = null
