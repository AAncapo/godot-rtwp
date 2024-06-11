extends Camera3D

@onready var _visibility_cam:Camera3D = $VisibilitySubViewport/VisibilityCamera
@onready var _visibility_vwport:SubViewport = $VisibilitySubViewport
@onready var _mask_vwport:SubViewport = $MaskSubViewport
@onready var _screen_mesh:MeshInstance3D = $MeshInstance3D


func _ready() -> void:
	_sync_viewport_size()
	get_viewport().size_changed.connect(_sync_viewport_size)


func _process(delta: float) -> void:
	_visibility_cam.global_transform = global_transform
	_visibility_cam.fov = fov
	
	var fov_rad = deg_to_rad(fov)
	var vwport_size:Vector2i = _screen_mesh.get_viewport().size
	var aspect_ratio :=float(vwport_size.x) / vwport_size.y
	var height := tan(fov_rad / 2)
	var width := height * aspect_ratio
	_screen_mesh.transform.basis = Basis().scaled(Vector3(width,height,1.0))


func _sync_viewport_size():
	var root_vwport_size = get_viewport().size
	_visibility_vwport.size = root_vwport_size
	_mask_vwport.size = root_vwport_size
