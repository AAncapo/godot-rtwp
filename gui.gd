extends Control

func _process(_delta):
	$Paused.visible = get_tree().paused

func _on_equip_hgun_pressed() -> void:
	GameEvents.switch_weapon.emit("handgun")

func _on_equip_lmg_pressed() -> void:
	GameEvents.switch_weapon.emit("lmg")
