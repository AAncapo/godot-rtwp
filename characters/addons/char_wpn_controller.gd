extends Node3D
class_name WeaponController

signal equipped(new_equipped_wpn:Weapon)

##TODO: load a character stats resource to get all the combat data ##
@onready var wpnHolder = $"%wpn_holder"
@onready var ray = $RayCast3D
var starting_gun = preload("res://weapons/pistol.tscn")
var equipped_wpn:Gun


func _ready():
	await get_tree().create_timer(0.1).timeout
	if starting_gun:
		var gun = starting_gun.instantiate()
		equip_wpn(gun)


func attack():
	if equipped_wpn: 
		equipped_wpn.attack()
	else:
		#unarmed animations
		pass


func equip_wpn(wpn_to_equip:Gun):
	if equipped_wpn:
		equipped_wpn.queue_free()
	
	equipped_wpn = wpn_to_equip
	wpnHolder.add_child(equipped_wpn)
	equipped_wpn.on_equipped()
	
	ray.target_position = Vector3(0,0.5,-equipped_wpn._range)
	
	equipped.emit(equipped_wpn)


func pointing_at_target(_target):
	if !ray.is_colliding() && ray.get_collider() != _target:
#		owner.look_at(_target.global_position,Vector3.UP)
		#is doing the same shit in Combat process_physics
		return false
	return true
