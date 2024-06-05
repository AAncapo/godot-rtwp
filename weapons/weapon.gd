class_name Weapon extends Node3D

#enum Availability { EXCL, COMM, POOR, RARE }
#@export var avail = Availability.EXCL
@export var icon:Texture2D
@export var name_:String
enum Type { NONE = -1, MELEE, HANDGUN, RIFLE, SMG, SHTG, HVY }
@export var type = Type.NONE
@export var accuracy:int = 0 #weapon accuracy
@export var clip_size:int = 0
@export var rof:int = 1  #firerate (shots per turn)
enum Rel { NA, VR, ST, UR }  #reliability (VeryReliabl, Standard, Unreliabl)
@export var reliabl:Rel
@export var range_:float = 1
enum FireMode { SINGLE, BURST, SEMIAUTO, FULLAUTO }
@export var firemode:FireMode = FireMode.SINGLE

@export_category("Damage Calc")
@export var dice_amount:int = 1
enum Dice { D6 = 6, D10 = 10 }
@export var sides:Dice = Dice.D6
@export var modifier:int
var damage:int:
	get:
		randomize()
		var result:int = Fnff.roll(dice_amount, sides) + modifier
		return result


func attack():
	$muzzle/AnimationPlayer.play("fire")


func reload():
	pass


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
