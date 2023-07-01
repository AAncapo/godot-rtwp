extends Node3D

@onready var char_name: Label3D = $char_name
@onready var selindicator = $selection_indicator
@onready var detectRadius = $detection_radius
@onready var hr: MeshInstance3D = $hitrange_indicator
@onready var head_hp = $head_healthbar
@onready var animPlayer = $AnimationPlayer
var is_selected:bool


func _ready():
	selindicator.hide()
	GameEvents.hover_target.connect(__on_target_hover)


func update_head_healthbar(cur_hp:float,max_hp:float):
	var hp_mat = head_hp.get_surface_override_material(0)
	hp_mat.set_shader_parameter("progress", cur_hp/10)


func set_hr_indicator_radius():
	var _char:Character = owner
	hr.scale = Vector3(_char.hit_range * 2,_char.hit_range * 2 ,1.0)
	hr.get_surface_override_material(0).set_shader_parameter('width',0.2 / _char.hit_range)


func _on_character_selected():
	is_selected = true
	$AnimationPlayer.play("character animations/show_selection")

func _on_character_deselected():
	is_selected = false
	$target_pos.hide()
	selindicator.hide()

func _on_character_select_as_target():
	_on_character_selected()

func _on_character_deselect_as_target():
	_on_character_deselected()

func _on_character_damaged(current_health,max_health):
	update_head_healthbar(current_health,max_health)


func _on_character_mouse_entered():
	# if team enemy emit target hovered
	# only if a player character is selected
	if owner.team == 1:
		GameEvents.hover_target.emit(owner,true)
	char_name.show()
	head_hp.show()


func _on_character_mouse_exited():
	if owner.team == 1:
		GameEvents.hover_target.emit(owner,false)
	char_name.hide()
	head_hp.hide()


func __on_target_hover(target:Character,is_hovered:bool):
	var _char:Character = owner
	
	if !is_hovered:
		hr.hide()
	if is_selected && is_hovered && _char.is_enemy(target):
		# display hitrange
		set_hr_indicator_radius()
		hr.show()
