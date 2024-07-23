class_name Room extends Area3D

var connectors := []
@export var team:int = Global.ENEMY_TEAM


func is_room_equal_or_connected(_room):
	if _room == self: return true
	for c in connectors:
		if c.connected_rooms.has(_room) and c.is_connection_open:
			return true
	return false


func _on_body_entered(body: Node3D) -> void:
	if body.is_player():
		body.curr_zone = self
