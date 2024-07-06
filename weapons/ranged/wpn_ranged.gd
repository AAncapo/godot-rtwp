class_name RangedWeapon extends Weapon

signal clip_updated(_clip)
signal reload_requested

enum RangedType { HANDGUN, RIFLE, SMG, SHTG, HVY }
@export var ranged_type:RangedType

enum FireMode { SINGLE, BURST, SEMIAUTO, FULLAUTO }
@export var firemode := FireMode.SINGLE
@export var accuracy:int = 0 #weapon accuracy
@export var clip_size:int = 0
@export var rof:int = 1  #firerate (shots per turn)
var current_clip := 0


func _ready() -> void:
	current_clip = clip_size


func shoot():
	if current_clip > 0:
		current_clip -= 1
		clip_updated.emit(current_clip)
		$muzzle/AnimationPlayer.play("fire")
		return true
	reload_requested.emit()


func reload():
	current_clip = clip_size
	clip_updated.emit(current_clip)

#func instance_bullet():
	#if !_barrels: 
		#print("ERROR: Gun [",name,"] needs a 'barrels' node to fire!")
		#return
	#
	#for b in _barrels.get_children():
		#add_bullet_deviation(b)
		#var bullet: Bullet = projectile_packedScene.instantiate()
		##TODO: set as toplevel
		#bullet.init(wpn_owner, bullet_speed, bullet_max_dist)
		#environment_node.add_child(bullet)
		#bullet.global_position = b.global_position
		#bullet.global_rotation = b.global_rotation


#func eject_shell():
	#if shell:
		#var _new_shell:RigidBody3D = shell.instantiate()
		#environment_node.add_child(_new_shell)
		#
		#_new_shell.translation = shell_ejection.global_translation
		#var shell_rotation = randf_range(-90,90)
		#_new_shell.rotation_degrees = Vector3(shell_rotation,0,0)
		#var impulse_force = randf_range(5,8)
		#_new_shell.apply_central_impulse(shell_ejection.global_transform.basis.x * impulse_force)
