class_name Weapon extends Node3D

#enum Availability { EXCL, COMM, POOR, RARE }
#@export var avail = Availability.EXCL
@export var name_:String
enum Type { MELEE, PISTOL, SMG, RIFLE, SHTG, HVY }
@export var type = Type.MELEE:
	get: return Type.find_key(type).to_lower()
@export var accuracy:int = 0 #accuracy
@export var clip_size:int = 0
@export var rof:int = 1  #firerate (shots per turn)
enum Rel { VR, ST, UR, NA }  #reliability (VeryReliabl, Standard, Unreliabl)
@export var reliabl:Rel
@export var range:float = 1
@export var cost:float

@export_category("Damage Algorithm")
@export var dices:int = 1
enum Dice { D6 = 6, D10 = 10, D12 = 12, D20 = 20 }  #TODO: D4 & percentile dices
@export var dice:Dice = Dice.D6
@export var added_points:int
var damage:int:
	get:
		randomize()
		var result:int
		for d in range (dices + 1):
			result += randi_range(1, dice)
		return result + added_points


func shoot():
	print("shoot!")

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
