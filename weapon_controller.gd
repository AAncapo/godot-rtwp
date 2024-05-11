extends Node3D

@onready var anim = %AnimationTree
@onready var weaponsHolder = %BoneAttachment3D
var equipped_weapon:
	set(value):
		equipped_weapon = value
		get_parent().hit_range = 1 if not value else value.hit_range
		$RayCast3D.target_position = self.transform.basis.z * -get_parent().hit_range

func _ready() -> void:
	GameEvents.switch_weapon.connect(equip)
	anim.disarm()

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
			anim.hold(wname)
		else:
			w.visible = false
