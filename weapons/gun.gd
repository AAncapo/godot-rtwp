extends Weapon
class_name Gun

signal has_shoot

@export_node_path('Node3D') var firePoints
@export_node_path('Timer') var timer
@export var shellEjection: NodePath
@export var muzzleFlash: NodePath

@onready var fire_points = get_node_or_null(firePoints)
@onready var fr_timer: Timer = get_node_or_null(timer)
@onready var shell_ejection: Node3D = get_node_or_null(shellEjection)
@onready var muzzle: = get_node_or_null(muzzleFlash)
var soundPlayer
var environment_node #where the gun spawned objs and fx instantiate

var firepoints = []
var is_trigger_released = true
var ready_to_shoot = true


func _ready():
	randomize()
	_init_gun()


func attack():
	pull_trigger()

func hold():
	release_trigger()


func pull_trigger():
	match firemode:
		FireMode.SINGLE:
			if is_trigger_released:
				shoot()
		FireMode.AUTO:
			shoot()
		FireMode.BURST:
			if burst_shots_remaining:
				shoot()
#					burst_shots_remaining -= 1
	is_trigger_released = false


func release_trigger():
	is_trigger_released = true
#	reset_burst()


func shoot():
	if ready_to_shoot:
		ready_to_shoot = false
		play_effects()
		if firemode == FireMode.BURST:
			for _i in range(burst_shots_remaining):
				await get_tree().create_timer(0.05,false).timeout
				instance_bullet()
				burst_shots_remaining -= 1
			reset_burst()
		else:
			instance_bullet()
		
		fr_timer.start()
		eject_shell()
		has_shoot.emit()
		return true


func play_effects():
	if soundPlayer:
		soundPlayer.play_sound(shot_sfx)
	if muzzle:
		muzzle.play("muzzleflash")


func add_bullet_deviation(_firepoint:Marker3D ):
	_firepoint.rotation_degrees.y = randf_range(-spread_radius,spread_radius)


func instance_bullet():
	for fp in firepoints:
		add_bullet_deviation(fp)
		var bullet: Bullet = bullet_scn.instantiate()
		#TODO: set as toplevel
		bullet.init(wpn_owner, bullet_speed, bullet_max_dist)
		environment_node.add_child(bullet)
		bullet.global_position = fp.global_position
		bullet.global_rotation = fp.global_rotation


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


func _on_Timer_timeout():
	ready_to_shoot = true


func _init_gun():
	if fire_points:
		for child in fire_points.get_children():
			firepoints.append(child)
	reset_burst()
	
	if fr_timer:
		fr_timer.wait_time = firerate
		fr_timer.autostart = true
		fr_timer.one_shot = true
		fr_timer.timeout.connect(_on_Timer_timeout)
	
	soundPlayer = get_node_or_null("SoundPlayer")
	environment_node = get_tree().root
