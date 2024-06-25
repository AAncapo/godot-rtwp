extends Node3D

@export var doors:Array[NodePath]
@onready var interior_area:Area3D = $InteriorArea
@export_node_path("MeshInstance3D") var roof_path
@onready var roof = get_node(roof_path)


func _update_interior_area(body: Node3D) -> void:
	if is_player(body):
		var players_remaining = interior_area.get_overlapping_bodies()
		roof.visible = players_remaining.is_empty()


func _on_peek_area_body_entered(body: Node3D) -> void:
	pass # Replace with function body.


func _on_peek_area_body_exited(body: Node3D) -> void:
	pass # Replace with function body.


func is_player(body):
	if body.is_in_group(Global.UNIT_GROUP):
		if body.team == Global.PLAYER_TEAM:
			return true
	return false


