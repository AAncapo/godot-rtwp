class_name RangedWeapon extends Weapon

signal clip_updated(_clip)
signal reload_requested

enum RangedType { HANDGUN, SMG, SHOTGUN, ASSAULT_RIFLE, SNIPER_RIFLE, BOW, GRENADE_LAUNCHER, ROCKET_LAUNCHER }
@export var ranged_type:RangedType

enum FireMode { SINGLE, SEMIAUTO, FULLAUTO }
@export var firemode:FireMode
@export var accuracy:int = 0  #weapon accuracy
@export var rof:int = 2  #firerate (shots per turn)
@export_node_path("Marker3D") var firepoint_node
@onready var firepoint = get_node_or_null(firepoint_node)
var projectile = preload("res://weapons/projectile.tscn")
var ammo:Ammo


func init(__owner:Character):
	super.init(__owner)
	#find existent mag on inventory if empty
	if !ammo or ammo.is_empty():
		reload_requested.emit()


func attack():
	if !ammo or ammo.is_empty():
		reload_requested.emit()
		return false
	shoot()
	return true


func shoot():
	instance_bullet()
	ammo.current_amount -= 1
	clip_updated.emit(ammo.current_amount)
	$muzzle/AnimationPlayer.play("fire")


func reload():
	var new_ammo = get_ammo_from_inventory()
	if new_ammo: 
		new_ammo.is_equipped = true
		ammo = new_ammo
		clip_updated.emit(ammo.current_amount)


func get_ammo_from_inventory() -> Ammo:
	var inv = _owner.equipment.get_inventory_items()
	for i in inv:
		if i is Ammo and !i.is_equipped and !i.is_empty(): return i
	return null


func instance_bullet():
	if !firepoint: return
	
	var bullet:Projectile = projectile.instantiate()
	firepoint.add_child(bullet)


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
