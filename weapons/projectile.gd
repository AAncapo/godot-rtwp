class_name Projectile extends CharacterBody3D

signal reached_target

const MAX_DISTANCE := 100.0
@export var speed := 50.0
@onready var starting_pos:Vector3 = self.global_position
var has_reached_target := false


func _physics_process(delta: float) -> void:
	#has_reached_target = (get_slide_collision_count() > 0 and
	#(global_position - starting_pos).length() > MAX_DISTANCE)
	#
	#if has_reached_target:
		#reached_target.emit()
		#queue_free()
		#return
	
	var dir = -basis.z
	velocity = dir * speed
	if move_and_slide() or (global_position - starting_pos).length() > MAX_DISTANCE:
		reached_target.emit()
		queue_free()
