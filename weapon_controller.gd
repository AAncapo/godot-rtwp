extends Node

@onready var animController = %AnimationTree
@onready var weaponsHolder = %BoneAttachment3D
var active_weapon

func _ready() -> void:
	GameEvents.switch_weapon.connect(change_active_weapon)
	animController.disarm()

func change_active_weapon(wname):
	var wpns = weaponsHolder.get_children()
	if active_weapon and active_weapon.name == wname:
		animController.disarm()
		active_weapon.visible = false
		active_weapon = null
		return
	
	for w in wpns:
		if w.name == wname:
			w.visible = true
			active_weapon = w
			animController.update_holded(wname)
		else:
			w.visible = false
