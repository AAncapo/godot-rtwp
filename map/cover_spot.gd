class_name CoverSpot extends StaticBody3D

@onready var defcr:RayCast3D = $DefaultCoverRay
@onready var hcray:RayCast3D = $HighCoverRay
@onready var sspots:Array = $ShootSpots.get_children()
@onready var indicator = $MeshInstance3D
var is_occupied:bool = false
var is_high_cover:bool = false
var prefShootSpot:Vector3


func is_effective_cover(target:Character):
	configure_raycast(defcr, target)
	
	if defcr.is_colliding() && defcr.get_collider() != target:
		is_high_cover = !hcray.is_colliding()
		if is_high_cover:
			for ss in sspots:
				configure_raycast(ss, target)
				
				if ss.is_colliding() && ss.get_collider() == target:
					prefShootSpot = ss.global_position
					prefShootSpot.y = 0
					break
		else:
			prefShootSpot = hcray.global_position
			prefShootSpot.y = 0
	
	return prefShootSpot != null


func configure_raycast(ray,target):
	var dist = (target.global_position - ray.global_position).length()
	ray.look_at(target.global_position)
	ray.target_position = Vector3(0,0.5,-dist)
	ray.force_raycast_update()


func select():
	is_occupied=true
	indicator.visible=true

func deselect():
	is_occupied = false


func _on_mouse_entered():
	indicator.show()

func _on_mouse_exited():
	if !is_occupied:
		indicator.hide()
