extends Unit
class_name Character

signal damaged

## Base ##
var is_dead = false
@export var max_health : float = 10
var current_health : float = max_health:
	set(value):
		clamp(value,0,max_health)
		current_health = value
@export var detection_range: float = 10.0:
	set(value):
		detection_range = value
@export var portrait_texture : CompressedTexture2D
## Movement ##
@export var speed : float = 10.0
var run_spd : float = speed * 1.2
var alert_spd : float = speed * 0.75
var walk_spd : float = speed * 0.5
var safe_dist: float = 0.2
var base_safe_dist: float = 0.2
var interact_range: float = 1.5
var rot_spd : float = 25.0
## Combat ##
var hit_range: float = 2.0:
	set(value):
		hit_range = value
		optimal_hr = hit_range * 0.75
		
		$GUI/debug_mesh/hitrange.global_scale(Vector3(value*2,0.02,value*2))
		$GUI/debug_mesh/opt_range.global_scale(Vector3(optimal_hr*2,0.02,optimal_hr*2))
		detection_range = hit_range+5
var optimal_hr: float = 1.5
@export var aim_speed : float = 1.5

@onready var mov: CharacterMovement = $CharacterAI/Movement

var team_materials = [
	preload("res://materials/chars/team0material.tres"),
	preload("res://materials/chars/team1material.tres")
	]


func _ready():
	$Body/MeshInstance3D.set_surface_override_material(0,team_materials[team])


func take_damage(_owner:Character, dmg:float):
	current_health -= dmg
	GameEvents.update_clg.emit(_owner,str('deals ',dmg,' damage to '),self)
	GameEvents.update_char_ui.emit(self)
	if current_health <= 0:
		is_dead = true
		GameEvents.update_clg.emit(_owner,'killed',self)
		GameEvents.character_died.emit(self)
		
		visible= false
		await get_tree().create_timer(0.5).timeout
		queue_free()


func interact():
	var int_dialog = get_node_or_null('InteractionDialog')
	if int_dialog: 
		int_dialog.visible = true
		await get_tree().create_timer(3,false).timeout
		int_dialog.visible = false


func at_range_from(_target:Character) -> bool:
	var _range = hit_range if is_enemy(_target) else interact_range
	var dist: float = (_target.global_position - global_position).length()
	return dist < _range
