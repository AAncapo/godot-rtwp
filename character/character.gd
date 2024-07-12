class_name Character extends Unit

signal selected_action_updated(_action)  #connected to character portrait
signal detected

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var anim:AnimationController = %AnimationTree
@onready var ttimer := $TurnTimer
@onready var crosshair := $crosshair
@onready var bound_area := $BoundArea
@onready var actions := $Actions
@onready var stats:Stats = $Stats
@onready var equipment:CharacterEquipment = $Equipment

var is_turn:bool = true
var next_action:float = 2.0:
	set(val):
		next_action = max(val, 0)
		ttimer.wait_time = next_action

## values edited to match the MotionState (AnimCtr)
enum State { DOWNED = -1, IDLE, WORKING, ALERT, COMBAT }
var current_state:State = State.IDLE:
	set(value):
		if value == current_state: return
		previous_state = current_state
		current_state = value
		if current_state == State.ALERT:
			$DetectedIcon/Label3D/AnimationPlayer.play("detect")
var previous_state
var stealth_on:bool = false:
	set(value):
		stealth_on = value
		anim.motion_state = anim.MotionState.CROUCH if stealth_on else anim.MotionState.NORMAL
		actions.get_action("takedown").set_enabled.emit(stealth_on)

var target_vec = null:
	set(val):
		if val and val.length() > 0:
			nav.target_position = val
			target_vec = nav.target_position if nav.is_target_reachable() else null
			if !target_vec: #if vec still null (not reachable) check if its a wall
				#print(target)
				if target.normal.y == 0:
					var new_vec = val + target.normal
					new_vec.y = 0
					nav.target_position = new_vec
					target_vec = nav.target_position if nav.is_target_reachable() else null
		else: 
			target_vec = null
		if is_player(): _update_vec_visual(target_vec)
	get: return target_vec if target_vec != null else null
var target_unit:Unit:
	set(val):
		if target_unit: #Remove mark from previous target (if existed)
			if target_unit.team != Global.PLAYER_TEAM:
				target_unit.set_as_marked(false)
		target_unit = val
		crosshair.enabled = target_unit != null
		if target_unit:
			if target_unit.team != Global.PLAYER_TEAM:
				target_unit.set_as_marked(true)
			anim.motion_state = AnimationController.MotionState.ALERTED
			if selected_action != actions.get_action('takedown'):
				actions.get_action('attack').select()
		else:
			anim.aim(false)
			if !stealth_on:
				anim.motion_state = AnimationController.MotionState.NORMAL
				current_state = State.IDLE
var target_interaction:Interactable:
	set(value):
		target_interaction = value
		actions.get_action("interact").select()
var is_moving:bool:
	set(value):
		is_moving = value
		if is_moving:
			anim.move(is_running)
		else: anim.stop()
var is_running:bool:
	get:
		return is_player() and (current_state==0 or current_state==1) and !stealth_on
var selected_action:Action
#var is_leader:bool = false:
	#set(value):
		#is_leader = value
		#if is_player():
			#assignment = 0 if is_leader else 2
enum Assignment { NONE, PATROL, FOLLOW }
@export var assignment:Assignment
var current_job


func _ready() -> void:
	target_updated.connect(_on_target_updated)
	
	Global.add_unit(self)
	Global.unit_died.connect(_on_unit_died)
	
	actions.init(self)
	
	equipment.equipment_updated.emit(equipment.unarmed, true)
	
	ttimer.timeout.connect(_on_turn_started)
	next_action = 1
	end_turn()


func _physics_process(_delta: float) -> void:
	is_moving = target_vec and is_turn
	if is_moving:
		var dir = Vector3()
		dir = (nav.get_next_path_position() - self.global_position).normalized()
		velocity = dir * stats.SPEED
		move_and_slide()
		rotate_to(nav.get_next_path_position())
	
	## look at target while visible
	if target_unit:
		if check_visibility(target_unit):
			rotate_to(target_unit.global_position)


func _on_action_selected(_action, _is_selected):
	selected_action = _action if _is_selected else null
	selected_action_updated.emit(selected_action)
	
	if is_player():
		bound_area.update_range_visual(selected_action.range_ if selected_action else 0)


func _on_turn_started():
	if stats.is_dead: return
	
	is_turn = true
	if stats.at_death_door:
		stats.roll_death_save()


func end_turn():
	is_turn = false
	ttimer.start()


func rotate_to(_target:Vector3, rotation_speed:float = .2):
	if self.global_transform.origin.is_equal_approx(_target):
		return
	var new_transform = self.transform.looking_at(_target, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, rotation_speed)


func check_visibility(_target):
	var vcheck:RayCast3D = %VisibilityChecker
	vcheck.look_at(_target.global_position)
	var length = (_target.global_position - self.global_position).length()
	vcheck.target_position.z = -length * 1.2
	vcheck.target_position.y = _target.scale.y/2
	vcheck.force_raycast_update()  # doesnt need to be enabled for this to work
	return vcheck.get_collider() == _target


func _on_reload_request():
	if !equipment.equipped_wpn.get_ammo_from_inventory():
		if selected_action == actions.get_action("attack"):
			#switch to melee/unarmed
			equipment.equipment_updated.emit(equipment.equipped_wpn, false)
			equipment.equipment_updated.emit(equipment.unarmed, true)
			return
	equipment.equipped_wpn.actions.get_action("reload").select()


func take_damage(atk:Attack):
	## Alert from attack
	if team != Global.PLAYER_TEAM:
		if !target_unit && atk.actor:
			end_turn()
			target_unit = atk.actor
	var dmg = stats.calc_damage(atk)
	msg(Global.POPUP_NOTIF.NORMAL,str("-",dmg.amount))
	#TODO: display status in log


func choke():
	anim.choke()

func get_choked(die:bool):
	anim.get_choked(die)


func _on_unit_died(unit):
	if unit == self: 
		stats.is_dead = true
		anim.die()
		disable()
		print(self.name, " died")
	
	if target_unit == unit:
		target_unit = null


## the var target only updates by the user input (command) so this func can be used to check if a new target was selected by the user or the ai ;)
func _on_target_updated(new_target) -> void:
	if !is_enemy(new_target.collider):
		if target_unit: target_unit = null
		target_vec = new_target.position
	else:
		target_unit = new_target.collider
	if new_target is Interactable:
		print("click interactable")
		target_interaction = new_target


func _on_nav_target_reached() -> void:
	target_vec = null
	if selected_action == actions.get_action("interact"):
		actions.get_action("interact").execute()


func _on_detected() -> void:
	if stealth_on: stealth_on = false
	msg(Global.POPUP_NOTIF.NORMAL,"DETECTED")


func msg(pop, text = "", remove = false):
	bound_area.add_notification(pop,text,remove)


func set_as_marked(value:bool):
	bound_area.is_marked = value


func _update_vec_visual(pos):
	var pos_visual := $PositionIndicator
	var _anim := pos_visual.get_node("AnimationPlayer")
	if !pos:
		_anim.play("RESET")
	else:
		_anim.play('start')
		pos_visual.global_position = pos
		pos_visual.global_position.y = 0.05


func disable():
	$CollisionShape3D.disabled = true
	$BeehaveTree.enabled = false
	bound_area.clear_notifications()

#TODO [REFACTOR] i think i could use the same func without the set_equipped param, if unarmed is a wpn so it will never be TRULY unequipped
func _on_equipment_updated(_item: Item, _set_equipped: bool, link_idx: int = 0) -> void:
	if _item is Weapon: anim.update_equipped(_item)
	
	if _set_equipped:
		if _item.equipment_class == Item.EquipmentClass.WEAPON:
			if _item.weapon_class == Weapon.WeaponClass.RANGED:
				if !_item.reload_requested.is_connected(_on_reload_request):
					_item.reload_requested.connect(_on_reload_request)
		
		if _item.equipment_class == Item.EquipmentClass.GEAR:
			pass
		
		equipment.equip(_item,link_idx)
	else:
		if _item.equipment_class == Item.EquipmentClass.WEAPON:
			if _item.weapon_class == Weapon.WeaponClass.RANGED:
				if _item.reload_requested.is_connected(_on_reload_request):
					_item.reload_requested.disconnect(_on_reload_request)
		
		equipment.unequip(_item)
	
	_on_equipped_wpn_changed(equipment.equipped_wpn)
	_item.is_equipped = _set_equipped
	stats.update()


func _on_equipped_wpn_changed(_wpn:Weapon):
	actions.get_action("attack").icon = _wpn.icon
	actions.get_action("attack").range_ = _wpn.range_
	crosshair.target_position = crosshair.transform.basis.z * -_wpn.range_
