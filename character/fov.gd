extends Node3D

var update:bool = true
@onready var meshInstance := %MeshInstance3D

func _process(_delta: float) -> void:
	if update:
		gen_mesh()


func gen_mesh():
	var fov = 90.0
	var ray_count = 2
	var angle = 0.0
	var angle_increase = fov / ray_count
	var view_distance = 10.0

	var a_mesh = ArrayMesh.new()
	var vertices := PackedVector3Array([
		Vector3(0,.5,0),
		Vector3(3,.5,0),
		Vector3(3,.5,3),
	])
	
	var indices := PackedInt32Array([
		0,1,2
	])
	
	var array = []
	array.resize(Mesh.ARRAY_MAX)
	array[Mesh.ARRAY_VERTEX] = vertices
	array[Mesh.ARRAY_INDEX] = indices
	a_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	meshInstance.mesh = a_mesh
