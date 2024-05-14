extends Unit

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var btree:BeehaveTree = $BeehaveTree
@onready var anim:AnimationController = %AnimationTree
@onready var weaponsHolder = %BoneAttachment3D
@onready var detection_area:Area3D = $DetectionArea
#@onready var fov:Area3D = $FOV
@onready var crosshair:RayCast3D = $crosshair
#@onready var visibility_chkr = $VisibilityChecker

@export var fov_dist:float = 10.0
@export var walk_speed:float = 1.5
@export var min_desired_dist:float = .2

enum state { NORMAL, ALERT, COMBAT, DOWNED } 
#TODO: mover esto al animationController q es el unico q trabaja con states
var current_state = state.NORMAL:
	set(value):
		if current_state != value:
			print(self.name," entered state: ", state.find_key(value))
		current_state = value
		anim.state = state.find_key(current_state).to_lower()

var melee_range:float = 1.5
var hit_range:float = melee_range:
	set(value):
		hit_range = value
		#using_fists = hit_range == melee_range
var equipped_weapon:
	set(value):
		equipped_weapon = value
		hit_range = melee_range if not value else value.hit_range
		crosshair.target_position = crosshair.transform.basis.z * -hit_range
var is_moving:bool = false:
	set(val):
		is_moving = val
		if is_moving: anim.move()
		else: anim.stop()
var target_vec = null:
	set(val):
		if val and val.length() > 0: 
				nav.target_position = val #to check at next line if its reachable
				#(!) still assigned value to nav.target_pos
				target_vec = nav.target_position if nav.is_target_reachable() else null
		else: target_vec = null
		self.is_moving = target_vec != null
	get:
		if target_vec != null: return target_vec if target_vec != null else null
var target_unit:
	set(val):
		target_unit = val
		if target_unit: self.current_state = state.ALERT
		#(!) Do NOT change state to NORMAL if null - only when no enemies left in detection area


func _ready() -> void:
	Global.add_unit(self)
	self.current_state = state.NORMAL
	anim.disarm()
	
	init_nodes()
	
	selected.connect(_on_selected)

func init_nodes():
	#fov.get_node("CollisionShape3D").shape.size.z = fov_dist
	#fov.position.z = -fov_dist/2
	
	nav.target_desired_distance = min_desired_dist
	nav.path_desired_distance = min_desired_dist


func move_to(pos:Vector3, speed:float, look_at_path:bool = true):
	var dir = Vector3()
	dir = (nav.get_next_path_position() - self.global_position).normalized()
	velocity = dir * speed
	move_and_slide() #TODO: how to put this in a physics process
	
	if look_at_path:
		rotate_to(nav.get_next_path_position())


func rotate_to(target:Vector3, rotation_speed:float = .2):
	if self.global_transform.origin.is_equal_approx(target):
		return
	var new_transform = self.transform.looking_at(target, Vector3.UP)
	self.transform = self.transform.interpolate_with(new_transform, rotation_speed)


func equip(wname):
	var wpns = weaponsHolder.get_children()
	if equipped_weapon and equipped_weapon.name == wname:
		anim.disarm()
		equipped_weapon.visible = false
		equipped_weapon = null
		return
	
	for w in wpns:
		if w.name == wname:
			w.visible = true
			equipped_weapon = w
		else:
			w.visible = false
	
	anim.equip(wname)


func _on_target_updated(new_target) -> void:
	if not new_target.collider.is_in_group(Global.UNIT_GROUP):
		self.target_unit = null  #if unit.target changed directly means that is a 'direct command'
		#TODO: while in enemy range, keep aiming at it and remove from target_unit when outof range
		self.target_vec = new_target.position
	else:
		if new_target.collider.team != team:
			self.target_unit = new_target.collider


#func get_enemies_in_fov():
	#var detected_units = []
	#var bodies = fov.get_overlapping_bodies()
	#for b in bodies:
		#if b.get_groups().has(Global.UNIT_GROUP) and b.team != team:
			#detected_units.append(b)
	#return detected_units


func get_enemies_in_area():
	var detected = []
	var bodies = detection_area.get_overlapping_bodies()
	for b in bodies:
		if b.get_groups().has(Global.UNIT_GROUP) and b.team != team:
			detected.append(b)
	return detected


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(Global.UNIT_GROUP) and body.team != team:
		self.current_state = state.ALERT
		#all units enter alert, only AIDriven ones assign it as target
		if team != Global.PLAYER_TEAM and not target_unit:
			self.target_unit = body


func _on_detection_area_body_exited(body: Node3D) -> void:
	#no hace nada si ya existe un target_unit. la secuencia de attack en btree ya esta comprobando si el target sale del area ;)
	if body.is_in_group(Global.UNIT_GROUP) and body.team != team and not target_unit:
		var enemies_left = get_enemies_in_area()
		if not enemies_left: 
			self.current_state = state.NORMAL


func _on_navigation_agent_3d_target_reached() -> void:
	self.target_vec = null
	if not target_unit: target_unit = null
	self.is_moving = false


func _on_selected(sel:bool = true):
	if sel:
		add_commands_listener()
	else:
		remove_commands_listener()
	$SelectedRing.visible = sel
