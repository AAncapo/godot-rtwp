extends Node3D

@onready var dialog_box := $DialogBox


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_action_pressed("pause"):
		get_tree().paused = !get_tree().paused
	if event is InputEventKey and event.is_action_pressed("close"):
		get_tree().quit()


func _ready() -> void:
	randomize()
	Global.dialog_triggered.connect(_on_Global_dialog_triggered)
	Global.close_dialog.connect(_on_Global_close_dialog)
	Global.dialog_triggered.emit("mission_briefing")


func _on_Global_dialog_triggered(key:String):
	$GUI.hide()
	
	dialog_box.start(key)
	dialog_box.show()


func _on_Global_close_dialog():
	dialog_box.hide()
	$GUI.show()
