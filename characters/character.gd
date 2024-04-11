class_name Character extends Unit

signal damaged(attacker, cur_hp, max_hp)

var dead:bool = false
var damageable:bool = true
@export var max_hp:float = 10
var curr_hp:float = max_hp:
	set(value):
		clamp(value, 0, max_hp)
		curr_hp = value
		GameEvents.update_char_ui.emit(self)
@export var detection_range:float = 30.0
@export var portrait_texture:CompressedTexture2D

@export var speed: float = 10.0
var run_sp:float = speed * 1.2
var alert_sp:float = speed * 0.75
var walk_sp:float = speed * 0.5
var curr_safdist:float = 1.0:
	set(val):
		curr_safdist = val
		update_safdist(curr_safdist)  # Nav agent stopping distance.
var base_safdist:float = 1.0
var combat_safdist:float = 1.5  #a number between the hit range limit and the 75% of it. 
var rot_sp:float = 25.0

var hit_range:float = 2.0:
	set(value):
		hit_range = value
		combat_safdist = hit_range * 0.75
@export var aim_speed:float = 1.5

@onready var controller = $CharacterAI
@onready var mov:CharacterMovement = %Movement
@onready var wpnCtr = $CharacterAI/WeaponController
@onready var da = $CharacterAI/DetectionArea

@export var ai_enabled:bool = false

var curr_cspot:CoverSpot:
	set(val):
		if curr_cspot: curr_cspot.deselect()
		curr_cspot = val
		if !curr_cspot:
			is_behind_cover = false
			shootBehindCoverPos = Vector3()
			return
		curr_cspot.select()
var is_behind_cover:bool = false:
	set(val):
		if val: shootBehindCoverPos = curr_cspot.prefShootSpot
		is_behind_cover = val
var shootBehindCoverPos:Vector3


func _ready():
	mov._char = self
	da.radius = detection_range
	target_updated.connect(controller._on_target_updated)
	top_level = true #por alguna razon desde que movi la posicion de Players en playerteam se jodio la rotacion cuando se mueven y esto lo arregla :|
	set_gui_indicators()


func _process(delta):
	if team == 0:
		self.curr_hp = lerp(curr_hp, max_hp, delta)


func attack():
	wpnCtr.attack()


func take_damage(_owner:Character, dmg:float):
	if !damageable:
		return
	curr_hp -= dmg
	damaged.emit(_owner, curr_hp, max_hp)
	GameEvents.update_char_ui.emit(self)
	if curr_hp <= 0:
		dead = true
		GameEvents.character_died.emit(self)
		
		visible = false
		await get_tree().create_timer(0.5).timeout
		queue_free()


func at_range_from(_target:Character) -> bool:
	var _range = hit_range if is_enemy(_target) else base_safdist
	var dist:float = (_target.global_position - global_position).length()
	return dist < _range


func update_safdist(safdist):
	mov.agent.target_desired_distance = safdist


func set_gui_indicators():
	$Body/MeshInstance3D.get_surface_override_material(0).albedo_color = team_color
#	$GUI/detection_radius.scale=Vector3(detection_range,detection_range,1.0)
	$GUI/char_name.text = name
## trying to fix the !material errors when the character is freed (apparently a Godot 4 issue) ##
func _on_tree_exited():
	for i in $GUI.get_children():
		if i is MeshInstance3D:
			i.set_surface_override_material(0, null)
