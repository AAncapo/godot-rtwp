class_name Gun extends Weapon


enum FireMode { SINGLE, AUTO, BURST }
@export var firemode: FireMode = FireMode.SINGLE

@export_group("Required")
@export_node_path('Node3D') var barrels
@export var projectile_packedScene: PackedScene
@export_subgroup("Optional")
@export var shellEjection: NodePath
@export var muzzleFlash: NodePath

@export_group("Stats")
@export var shell: PackedScene
@export var bullet_speed: float = 100.0
@export var spread_radius: float  #degrees
@onready var _barrels = get_node_or_null(barrels)
@onready var shell_ejection: Node3D = get_node_or_null(shellEjection)
@onready var muzzle := get_node_or_null(muzzleFlash)
@export_subgroup('Burst FireMode')
@export var burst_shots: int
var bullet_max_dist:float = 70.0
var burst_shots_remaining: int
var soundPlayer
#TODO: change environment node as get_tree.root for a 'pool' node inside the gun scene and set the bullet as toplevel
var environment_node #where the gun spawned objs and fx instantiate

var is_trigger_released = true
var ready_to_shoot = true

# attack() > starts aiming... > aiming complete > pull_trigger() > start shooting > if SINGlE release trigger after shoot confirmed else  -> release_trigger() 
func _ready():
	randomize()
	_init_gun()


## is called every frame from Combat State ##
func attack():
	# aqui pull_trigger esa emulando el tiempo que el character mantiene apretado el gatillo,
	# cada arma tiene uno o mas modos en los que pueden ser utilizadas por ejemplo:
	# Pistol -> SINGLE,BURST / AssaultRifle -> SINGLE,BURST,AUTO / GrenadeLauncher -> SINGLE
	match firemode:
		FireMode.SINGLE:
			hold_trigger()
		FireMode.AUTO:
			hold_trigger()
		FireMode.BURST:
			if burst_shots_remaining:
				hold_trigger()
#				burst_shots_remaining -= 1


func release_trigger():
	is_trigger_released = true
#	reset_burst()

func hold_trigger():
	if ready_to_shoot:
		ready_to_shoot = false
		play_effects()
#		if firemode == FireMode.BURST:
#			for _i in range(burst_shots_remaining):
#				await get_tree().create_timer(0.05,false).timeout
#				instance_bullet()
#				burst_shots_remaining -= 1
#			reset_burst()
#		else:
		instance_bullet()
		
		cooldown_timer.start()
		eject_shell()
		return true


func play_effects():
	if soundPlayer:
		soundPlayer.play_sound(shot_sfx)
	if muzzle:
		muzzle.play("muzzleflash")


func add_bullet_deviation(_firepoint:Marker3D ):
	_firepoint.rotation_degrees.y = randf_range(-spread_radius,spread_radius)


func instance_bullet():
	if !_barrels: 
		print("ERROR: Gun [",name,"] needs a 'barrels' node to fire!")
		return
	
	for b in _barrels.get_children():
		add_bullet_deviation(b)
		var bullet: Bullet = projectile_packedScene.instantiate()
		#TODO: set as toplevel
		bullet.init(wpn_owner, bullet_speed, bullet_max_dist)
		environment_node.add_child(bullet)
		bullet.global_position = b.global_position
		bullet.global_rotation = b.global_rotation


func eject_shell():
	if shell:
		var _new_shell:RigidBody3D = shell.instantiate()
		environment_node.add_child(_new_shell)
		
		_new_shell.translation = shell_ejection.global_translation
		var shell_rotation = randf_range(-90,90)
		_new_shell.rotation_degrees = Vector3(shell_rotation,0,0)
		var impulse_force = randf_range(5,8)
		_new_shell.apply_central_impulse(shell_ejection.global_transform.basis.x * impulse_force)


func on_equipped():
	if active_sfx && soundPlayer:
		soundPlayer.play_sound(active_sfx)


func reset_burst():
	burst_shots_remaining = burst_shots


func _on_cooldown_timer_timeout():
	ready_to_shoot = true


func _init_gun():
	bullet_max_dist = _range*2
	reset_burst()
	
	if cooldown_timer:
		cooldown_timer.wait_time = cooldown
		cooldown_timer.autostart = true
		cooldown_timer.one_shot = true
		cooldown_timer.timeout.connect(_on_cooldown_timer_timeout)
	else:
		printerr("Connect a 'cooldown_timer'!")
	
	soundPlayer = get_node_or_null("SoundPlayer")
	environment_node = get_tree().root
