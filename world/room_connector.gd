extends Area3D
# Keeps track of connections between rooms (2)
# Is in charge of calling the open/close functions in the assigned door (if any)

@export var auto_door:bool #open/close doors on unit detection
var connected_rooms := []
var door:Door
var is_connection_open := true  #is door open or does have a door(always true if not)


func _ready() -> void:
	#TODO get_overlapping no funciona pero si area_entered (???)
	#for area in get_overlapping_areas():
		#if area is Room:
			#area.connectors.append(self)
			#connected_rooms.append(area)
	
	for child in get_children():
		if child is Door:
			door = child
			is_connection_open = door.is_open


#TODO peek (light up neighboor room) when is_open and body entered or hide otherwise
func _on_body_entered(_body: Node3D) -> void:
	#if door:
		#is_connection_open = door.is_open
		#if auto_door:
			#if !door.is_open: door.open()
			#is_connection_open = true
		#return
	
	if !is_connection_open: is_connection_open = true


func _on_body_exited(_body: Node3D) -> void:
	if get_overlapping_bodies().is_empty():
		if door and auto_door and door.is_open: door.close()
		is_connection_open = false


func _on_area_entered(area: Area3D) -> void:
	if area is Room:
		connected_rooms.append(area)
		area.connectors.append(self)
		#print(area.name, " added to ",name," connected_rooms")
