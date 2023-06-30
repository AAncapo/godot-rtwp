extends Control


func _process(_delta):
	$VBoxContainer/fps_counter.text = str('fps: ',Engine.get_frames_per_second())


func _on_hide_hud_toggled(button_pressed):
	%HUD.visible = !button_pressed


func _on_reset_pressed():
	get_tree().reload_current_scene()
