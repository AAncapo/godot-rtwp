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
var projectile = preload("res://items/weapons/projectile.tscn")
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
	super.attack()
	return true


func shoot():
	instance_bullet()
	ammo.current_amount -= 1
	clip_updated.emit(ammo.current_amount)
	$muzzle/AnimationPlayer.play("fire")

func reload():
	var new_ammo = get_ammo_from_inventory()
	if new_ammo: 
		#new_ammo.is_equipped = true  #(!!!) the update slots func en inventoryUi
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

#TODO: firemode.AUTO DV table (pg.173)
#distances in meters
const DIST_TABLE = [[0,6], [7,12], [13,25], [26,50], [51,100], [101,200], [201,400], [401,800]]
const RANGE_BASED_DV = {
	RangedType.HANDGUN          :[  13,     15,    20,     25,     30,    30,     -1,     -1 ], 
	RangedType.SMG              :[  15,     13,    15,     20,     25,    25,     30,     -1 ], 
	RangedType.SHOTGUN          :[  13,     15,    20,     25,     30,    35,     -1,     -1 ], 
	RangedType.ASSAULT_RIFLE    :[  17,     16,    15,     13,     15,    20,     25,     30 ], 
	RangedType.SNIPER_RIFLE     :[  30,     25,    25,     20,     15,    16,     17,     20 ],
	RangedType.BOW              :[  15,     13,    15,     17,     20,    22,     -1,     -1 ],
	RangedType.GRENADE_LAUNCHER :[  16,     15,    15,     17,     20,    22,     25,     -1 ],
	RangedType.ROCKET_LAUNCHER  :[  17,     16,    15,     15,     20,    20,     25,     30 ]
	}
func get_range_dv(actor_pos:Vector3, target_pos:Vector3) -> int:
	#returns a DV (difficulty value) based on the distance to target (-1 if out of range)
	
	var dv_table_row:Array = RANGE_BASED_DV[ranged_type]
	var distance:float = (actor_pos - target_pos).length()
	
	var dist_index:int
	for d in DIST_TABLE as Array:
		if distance in range(d[0], d[1]+1):
			dist_index = d.get_index()
			break
	
	var range_dv: int = dv_table_row[dist_index]
	return range_dv
