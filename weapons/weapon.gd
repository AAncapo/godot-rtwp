class_name Weapon extends Node3D

enum WeaponType { MELEE, HANDGUN, SHOTGUN, RIFLE, LAUNCHER } 

@export var wpn_type: WeaponType = WeaponType.HANDGUN 
@export var miniature_image : CompressedTexture2D
@export var _range: float = 2.0
@export_node_path('Timer') var timer
@export var cooldown: float = 1.0  # in melee wpn is the attack animation duration + whatever arbitrary extra time it needs to be ready for the next attack (gun: characters aim time)
@export_group('Sound Effects')
@export var shot_sfx: AudioStream
@export var active_sfx: AudioStream  #play when equipped
@export var reload_sfx: AudioStream
@export var empty_sfx: AudioStream

@onready var cooldown_timer: Timer = get_node_or_null(timer)

var wpn_owner:Character


func attack():
	pass
