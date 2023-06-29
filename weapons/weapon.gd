extends Node3D
class_name Weapon

enum WeaponType { 
	MELEE, 
	HANDGUN, 
	SHOTGUN, 
	RIFLE, 
	LAUNCHER 
	} 
enum FireMode { 
	SINGLE, 
	AUTO, 
	BURST 
	}

@export_group('General Stats')
@export var wpn_tag : String
@export var weapon_type: WeaponType = WeaponType.HANDGUN 
@export var firemode: FireMode = FireMode.AUTO
@export var miniature_image : CompressedTexture2D
@export var wpn_range: float = 2.0

@export_group('GUNS')
@export var bullet_scn: PackedScene
@export var shell: PackedScene
@export var firerate: float = 0.1  #miliseconds
@export var auto_fire: bool = true
@export var use_ammo: bool = false
@export var ammo_per_shot: int = 1
@export var bullet_speed: float = 150.0
@export var bullet_max_dist: float = 70.0
@export var spread_radius: float  #degrees

@export_subgroup('Burst FireMode')
@export var burst_shots: int
var burst_shots_remaining: int

@export_subgroup('Heat')
@export var generate_heat: bool = false
@export var heat_generated: int = 10


@export_group('Sound Effects')
@export var shot_sfx: AudioStream
@export var active_sfx: AudioStream  #play when equipped
@export var reload_sfx: AudioStream
@export var empty_sfx: AudioStream

var wpn_owner:Character


func attack():
	pass

func hold():
	pass
