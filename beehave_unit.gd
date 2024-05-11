extends Unit

@onready var btree:BeehaveTree = $BeehaveTree
@onready var nav_agent:NavigationAgent3D = $NavigationAgent3D
@onready var anim:AnimationTree = %AnimationTree

@export var walk_speed:float = 1.5
@export var ROTATION_SPEED = 0.2

var fist_range:float = 1.5
var hit_range:float = fist_range:
	set(value):
		hit_range = value
		using_fists = hit_range == fist_range
var using_fists:bool = hit_range == fist_range

func _ready() -> void:
	selected.connect(_on_selected)
	deselected.connect(_on_deselected)


func rotate_to(target:Vector3):
	if self.global_transform.origin.is_equal_approx(target):
		return
	var new_transform = self.transform.looking_at(target, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, ROTATION_SPEED)


func _on_selected():
	add_commands_listener()
	$SelectedRing.show()


func _on_deselected():
	remove_commands_listener()
	$SelectedRing.hide()


func _on_target_updated(new_target: Variant) -> void:
	if not new_target.collider.is_in_group("units"):
		nav_agent.target_position = new_target.position


func _on_detection_area_body_entered(body: Node3D) -> void:
	pass
	#if body.is_in_group("units") and body.team != 1:
		#print("enemy detected")