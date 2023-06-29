extends Node3D
class_name WeaponController

signal equipped(new_equipped_wpn:Weapon)

var starting_gun = preload("res://weapons/pistol.tscn")

## load a character stats resource to get all the combat data ##
@export var aim_spd: float = 0.5

@onready var wpnHolder = $"%wpn_holder"
@onready var ray = $RayCast3D
@onready var aim_timer: float

var equipped_wpn: Gun
var aimed = false
var ammo: int
#var target: Character


func _ready():
	await get_tree().create_timer(0.1).timeout
	if starting_gun:
		var gun = starting_gun.instantiate()
		equip_wpn(gun)


func attack(delta):
	aim_timer -= delta
	if aim_timer <= 0:
		if equipped_wpn:
			aim_timer = aim_spd
			#### adaptar gun.shoot a este tipo de jugabilidad ####
			equipped_wpn.attack()
			equipped_wpn.hold()
		else:
			#unarmed animations
			pass
	else:
		#the target escaped hit range
		
		pass


func equip_wpn(wpn_to_equip:Gun):
	if equipped_wpn:
		equipped_wpn.queue_free()
	
	equipped_wpn = wpn_to_equip
	wpnHolder.add_child(equipped_wpn)
	equipped_wpn.on_equipped()
	equipped_wpn.has_shoot.connect(_on_equipped_has_shoot)
	
	ray.target_position = Vector3(0,0,-equipped_wpn.wpn_range)
	
	equipped.emit(equipped_wpn)


func pointing_at_target(_target):
	var collidr = ray.get_collider()
	return collidr && collidr == _target


func _on_equipped_has_shoot():
#	aimed = false
	pass
