extends Control

@onready var healthBar = $VBoxContainer/HealthBar
#@onready var charName = $character_name
@onready var portrait = $VBoxContainer/bg_portrait/Portrait
@onready var port_bg = $VBoxContainer/bg_portrait
@onready var hp_counter = $VBoxContainer/HealthBar/health_counter
var char_owner: Character : set = setCharacterOwner


func _ready():
	GameEvents.update_char_ui.connect(on_character_ui_updated)


func setCharacterOwner(value):
	char_owner = value
	portrait.texture_normal = char_owner.portrait_texture
#	charName.text = char_owner.name
	healthBar.max_value = char_owner.max_health
	healthBar.value = char_owner.current_health
	hp_counter.text = str(healthBar.value,'/',healthBar.max_value)


func on_character_ui_updated(_char: Character):
	if char_owner && _char == char_owner:
#		charName.text = _char.name
		healthBar.value = _char.current_health
		hp_counter.text = str(healthBar.value,'/',healthBar.max_value)


func _on_portrait_pressed():
	#select character
	char_owner.selected.emit()
	GameEvents.focus_worldobject.emit(char_owner)


func _on_health_bar_mouse_entered():
	$VBoxContainer/HealthBar/health_counter.show()
func _on_health_bar_mouse_exited():
	$VBoxContainer/HealthBar/health_counter.hide()
