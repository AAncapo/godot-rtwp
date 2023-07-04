extends Unit
class_name Character

signal damaged(cur_hp,max_hp)

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
var optimal_hr: float = 1.5
@export var aim_speed : float = 1.5

@onready var mov: CharacterMovement = $Movement
@onready var da: DetectionArea = $DetectionArea


func _ready():
	$CharacterAI._char = self
	damaged.emit(current_health,max_health)
	$Body/MeshInstance3D.get_surface_override_material(0).albedo_color = team_color
	set_gui_indicators()
#	$BehaviourRoot.actor = self


func take_damage(_owner:Character, dmg:float):
	current_health -= dmg
	damaged.emit(current_health,max_health)
	GameEvents.update_clg.emit(_owner,str('deals ',dmg,' damage to '),self)
	GameEvents.update_char_ui.emit(self)
	if current_health <= 0:
		is_dead = true
		GameEvents.update_clg.emit(_owner,'killed',self)
		GameEvents.character_died.emit(self)
		
		visible = false
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


func set_gui_indicators():
	$GUI/detection_radius.scale=Vector3(detection_range*2,detection_range*2,1.0)
	$GUI/char_name.text = name
## trying to fix the !material errors when the character is freed (apparently a Godot 4 issue) ##
func _on_tree_exited():
	for i in $GUI.get_children():
		if i is MeshInstance3D:
			i.set_surface_override_material(0, null)
