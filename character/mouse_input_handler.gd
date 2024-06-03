extends Area3D

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	await get_parent().ready
	get_parent().selected.connect(_on_character_selected)


func _on_mouse_entered():
	_on_mouse_over(true)
func _on_mouse_exited():
	_on_mouse_over(false)
func _on_mouse_over(mo:bool):
	if not get_parent().is_selected: $SelectionRing.visible = mo


func _on_character_selected(sel: bool) -> void:
	$SelectionRing.visible = sel
	
