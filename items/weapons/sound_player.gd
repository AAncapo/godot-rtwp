class_name SoundPlayer extends Node3D


func play_sound(sound):
	var players := get_children()
	for asp:AudioStreamPlayer3D in players:
		if !asp.playing:
			asp.stream = sound
			asp.play()
			return
