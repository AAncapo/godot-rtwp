class_name Door extends Interactable

@onready var player_link:NavigationLink3D = $player_link
@onready var npc_link:NavigationLink3D = $npc_link
@export_node_path("AnimationPlayer") var animation_player
var is_open:bool = false


func _ready() -> void:
	player_link.enabled = false #needs to be enabled when NavigationRegion loads so it can be taken into account


func interact():
	if is_open: close() 
	else: open()


func open():
	var anim = get_node_or_null(animation_player)
	if anim:
		anim.play("open_door")
		player_link.enabled = true
	is_open = true


func close():
	var anim = get_node_or_null(animation_player)
	if anim:
		anim.play("close_door")
		player_link.enabled = false
	is_open = false
