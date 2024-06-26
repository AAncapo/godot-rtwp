extends Node3D

@onready var player_link:NavigationLink3D = $player_link
@onready var npc_link:NavigationLink3D = $npc_link
@export_node_path("AnimationPlayer") var animation_player
@export var active := false
var is_open:bool = false


func _ready() -> void:
	if active: player_link.enabled = false #needs to be enabled when NavigationRegion loads so it can be taken into account


func open():
	var anim = get_node_or_null(animation_player)
	if anim:
		anim.play("open_door")
		player_link.enabled = true


func close():
	var anim = get_node_or_null(animation_player)
	if anim:
		anim.play("close_door")
		player_link.enabled = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if active: open()


func _on_area_3d_body_exited(body: Node3D) -> void:
	if active: close()
