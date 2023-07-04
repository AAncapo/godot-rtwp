extends Control


func _process(_delta):
	$VBoxContainer/fps_counter.text = str('fps: ',Engine.get_frames_per_second())


func _on_hide_hud_toggled(button_pressed):
	%HUD.visible = !button_pressed


func _on_reset_pressed():
	get_tree().reload_current_scene()

func _on_refill_hp_pressed():
	var units = get_tree().get_nodes_in_group('units') as Array[Character]
	for u in units:
		u.current_health = u.max_health
