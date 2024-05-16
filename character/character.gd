extends Unit

signal detected
signal damaged

@onready var nav:NavigationAgent3D = $NavigationAgent3D
@onready var anim:AnimationController = %AnimationTree
@onready var weapons = %Weapon1
@onready var detection_area:Area3D = $DetectionArea  #more like awareness/perception
@onready var fov:Area3D = $FieldOfView
@onready var crosshair:RayCast3D = $crosshair
@onready var info = $Info
@onready var action_timer:Timer = $ActionTimer

var next_action:float = 3.2:
	set(val):
		next_action = max(val, 0)
		action_timer.wait_time = next_action
var time_left:float:
	get: return action_timer.time_left

@export var visibility_range:float = 10.0
@export var walk_speed:float = 1.5
@export var min_desired_dist:float = .2

#TODO: mover esto al animationController q es el unico q trabaja con states
enum state { NORMAL, ALERT, DOWNED, DEAD } 
var current_state = state.NORMAL:
	set(value):
		if current_state != value:
			print(self.name," entered state: ", state.find_key(value))
		current_state = value
		anim.state = state.find_key(current_state).to_lower()
var is_dead:bool = false:
	set(val):
		is_dead = val
		$CollisionShape3D.disabled = is_dead
		if is_dead: 
			print(self.name, " died")
			self.current_state = state.DEAD
@export var max_health:float = 10.0
@export var health:float = max_health:
	set(val):
		health = val
		$Info.update(max_health,health)
var melee_range:float = 1.5
var hit_range:float = melee_range

var equipped_weapon:Weapon
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
var stealth_active:bool = false:
	set(val):
		stealth_active = val
		#set animation state
		print(self.name," entered" if stealth_active else " exited", " stealth")


func _ready() -> void:
	self.next_action = 3.2
	Global.add_unit(self)
	Global.unit_died.connect(_on_unit_died)
	self.current_state = state.NORMAL
	anim.disarm()
	update_fov()
	
	nav.target_desired_distance = min_desired_dist
	nav.path_desired_distance = min_desired_dist
	selected.connect(_on_selected)
	self.health = max_health

func _process(delta: float) -> void:
		info.visible = time_left < next_action and time_left > 0
		if info.visible: info.update(time_left,next_action)


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


func equip(new_wpn:Weapon):
	if equipped_weapon and equipped_weapon == new_wpn:
		anim.disarm()
		equipped_weapon.visible = false
		equipped_weapon = null
		return
	
	var wpns = weapons.get_children()
	for w in wpns:
		if w == new_wpn:
			w.visible = true
			self.equipped_weapon = w
		else:
			w.visible = false
	hit_range = melee_range if not equipped_weapon else equipped_weapon.range
	crosshair.target_position = crosshair.transform.basis.z * -hit_range
	anim.equip(new_wpn.type)


func attack(target:Unit):
	var dmg = equipped_weapon.damage if equipped_weapon else 1
	print(self.name," deals ",dmg," to ",target.name)
	target.take_damage(self, dmg)


func take_damage(actor, dmg):
	damaged.emit()
	self.health -= dmg
	if health <= 0:
		Global.unit_died.emit(self)


func _on_target_updated(new_target) -> void:
	if not new_target.collider.is_in_group(Global.UNIT_GROUP):
		self.target_unit = null 
		#TODO: while in enemy range, keep aiming at it and remove from target_unit when outof range
		self.target_vec = new_target.position
	else:
		if new_target.collider.team != team:
			self.target_unit = new_target.collider


func _on_unit_died(unit):
	if unit == self: 
		self.is_dead = true
		if Global.selected_units.has(unit):
			Global.selected_units.remove_at(Global.selected_units.find(unit))
	if target_unit == unit:
		self.target_unit = null


func update_fov():
	fov.get_node("CollisionShape3D").shape.size.z = visibility_range
	fov.position.z = -visibility_range/2

func get_enemies_in_area(area:Area3D = null):
	var detected_units = []
	var bodies = []
	if not area: #if no area is specified. check all (detection & fov)
		bodies = detection_area.get_overlapping_bodies()
		bodies.append_array(fov.get_overlapping_bodies())
	else:
		bodies = area.get_overlapping_bodies()
	for b in bodies:
		if b.get_groups().has(Global.UNIT_GROUP) and b.team != team and check_visibility(b):
			detected_units.append(b)
	return detected_units


func _on_detection_area_body_entered(body: Node3D) -> void:
	if body.is_in_group(Global.UNIT_GROUP) and body.team != team and not body.stealth_active:
		self.current_state = state.ALERT
		#all units enter alert, only AIDriven ones assign it as target
		if team != Global.PLAYER_TEAM and not target_unit:
			if check_visibility(body):
				self.target_unit = body
			else:
				self.target_vec = body.global_position

func _on_detection_area_body_exited(body: Node3D) -> void:
	#no hace nada si ya existe un target_unit. la secuencia de attack en btree ya esta comprobando si el target sale del area ;)
	if (body.is_in_group(Global.UNIT_GROUP) 
	and body.team != team 
	and not target_unit
	and not body.stealth_active):
		var enemies_left = get_enemies_in_area(detection_area)
		if not enemies_left: 
			self.current_state = state.NORMAL


func _on_field_of_view_body_entered(body: Node3D) -> void:
	if body.is_in_group(Global.UNIT_GROUP) and body.team != team:
		body.detected.emit()
		self.current_state = state.ALERT
		#all units enter alert, only AIDriven ones assign it as target
		if team != Global.PLAYER_TEAM and not target_unit:
			if check_visibility(body):
				self.target_unit = body
			else:
				self.target_vec = body.global_position


func _on_navigation_agent_3d_target_reached() -> void:
	self.target_vec = null
	if not target_unit: target_unit = null
	self.is_moving = false


func _on_selected(sel:bool = true):
	if sel: add_commands_listener()
	else: remove_commands_listener()
	$SelectedRing.visible = sel


func _on_detected() -> void:
	if stealth_active: stealth_active = false


func check_visibility(target):
	var vcheck:RayCast3D = $VisibilityChecker
	vcheck.target_position = target.global_position
	vcheck.target_position.y = target.scale.y/2
	vcheck.force_raycast_update()  # doesnt need to be enabled for this to work
	
	return vcheck.get_collider() == target
