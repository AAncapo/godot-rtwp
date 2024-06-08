extends Control

@onready var fps = $fps
@onready var portraits = %portraits
@onready var actions_view := %Actions
@onready var ranged_clip := %RangedClip
var portrait_tscn = preload("res://gui/portrait.tscn")
var equipped_ranged:RangedWeapon:
	set(value):
		equipped_ranged = value
		if equipped_ranged:
			if !equipped_ranged.clip_updated.is_connected(_on_ranged_clip_updated):
				equipped_ranged.clip_updated.connect(_on_ranged_clip_updated)
var displayed_unit


func _ready() -> void:
	clear_buttons()
	Global.added_unit.connect(_on_added_unit)  #init portraits
	Global.unit_selected.connect(_on_Global_selected_unit)
	Global.unit_deselected.connect(_on_Global_deselected_unit)


func _process(_delta):
	fps.text = str(Engine.get_frames_per_second(),"fps")
	$Paused.visible = get_tree().paused


func _on_added_unit(unit):
	if unit.is_player():
		var port = portrait_tscn.instantiate()
		portraits.add_child(port)
		port.unit = unit


func _on_Global_selected_unit(_unit):
	if _unit == displayed_unit: return
	
	displayed_unit = _unit
	clear_buttons()
	show_unit_actions(true)
	
	for a in _unit.actions.get_children():
		a.init() ## init to get the current state (mainly to set&get the count)
		
		## assign to button
		if _unit.actions.get_action("attack") != a:
			actions_view.get_child(a.get_index()-1).action = a
		else:
			%Equipped.action = _unit.actions.get_action("attack")
			update_clip_view(%Equipped.action.count)
			var unit_wpn = _unit.equipped_wpn
			if unit_wpn is RangedWeapon:
				equipped_ranged = unit_wpn
				#TODO change to on_new_equipped
			update_weapon_actions_view(unit_wpn)


func _on_Global_deselected_unit(_unit):
	if _unit != displayed_unit:
		return
	displayed_unit = null
	clear_buttons()


func clear_buttons():
	show_unit_actions(false)
	%Equipped.action = null
	ranged_clip.hide()
	for btn in actions_view.get_children():
		btn.action = null


func update_weapon_actions_view(wpn:Weapon):
	var wpn_actions_view = %EquippedActions.get_children()
	for w in wpn_actions_view:
		w.hide()
	var wpn_actions = wpn.actions.get_children()
	for w in wpn_actions:
		wpn_actions_view[w.get_index()].show()
		wpn_actions_view[w.get_index()].action = w


func update_clip_view(_count):
	for b in ranged_clip.get_children():
		b.hide()
	for b in range(_count):
		ranged_clip.get_child(b).show()
	ranged_clip.show()


func _on_ranged_clip_updated(_count):
	update_clip_view(_count)
	#var bullet_icons = ranged_clip.get_children()
	#if equipped_ranged.current_clip < bullet_icons.size():
		##TODO remove animation
		#pass
	#else:
		##TODO refill animation
		#pass


func show_unit_actions(_show):
	for control in get_tree().get_nodes_in_group("unit_actions"):
		control.modulate = Color('ffffff') if _show else Color('ffffff64')
