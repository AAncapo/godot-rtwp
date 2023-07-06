extends Control

@onready var healthBar = $VBoxContainer/HealthBar
@onready var portrait = $VBoxContainer/bg_portrait/Portrait
@onready var port_bg = $VBoxContainer/bg_portrait
@onready var hp_counter = $VBoxContainer/HealthBar/health_counter
var _char: Character:
	set(value):
		_char = value
		portrait.disabled = value==null
		if value != null:
			healthBar.show()
			portrait.texture_normal = _char.portrait_texture
			healthBar.max_value = _char.max_health
			healthBar.value = _char.current_health
			hp_counter.text = str(healthBar.value,'/',healthBar.max_value)


func _ready():
	portrait.disabled = true
	healthBar.hide()
	
	GameEvents.update_char_ui.connect(on_character_ui_updated)
	GameEvents.character_died.connect(__on_character_died)


func on_character_ui_updated(character: Character):
	if _char && _char == character:
		healthBar.value = character.current_health
		hp_counter.text = str(healthBar.value,'/',healthBar.max_value)


func _on_portrait_pressed():
	#select character
	if _char:
		print(_char.name, 'selected')
		_char.selected.emit()
		GameEvents.focus_world_object.emit(_char)


func __on_character_died(character):
	if _char && _char == character:
		#set portrait as disabled
		portrait.disabled = true
		portrait.show_behind_parent = true


func _on_health_bar_mouse_entered():
	$VBoxContainer/HealthBar/health_counter.show()
func _on_health_bar_mouse_exited():
	$VBoxContainer/HealthBar/health_counter.hide()
