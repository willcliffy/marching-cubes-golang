@tool
extends Node3D

@onready var highlight: MeshInstance3D = get_node("Highlight")
@onready var terrain: MeshInstance3D = get_node("Terrain")

@export_group("Marching Cubes Parameters")

@export
var size := Vector3i(100, 25, 100):
	set(new_value):
		size = new_value
		queue_rebuild()

@export
var iso_level := 0.7:
	set(new_value):
		iso_level = new_value
		queue_rebuild()

@export_group("Noise Parameters")

@export
var base_noise: FastNoiseLite:
	set(new_value):
		base_noise = new_value
		queue_rebuild()

@export
var additive_gradient: Curve:
	set(new_value):
		additive_gradient = new_value
		queue_rebuild()

@export
var multiplicative_gradient: Curve:
	set(new_value):
		multiplicative_gradient = new_value
		queue_rebuild()

@export_group("Terrain Parameters")

@export
var material_override: ShaderMaterial:
	set(new_material):
		material_override = new_material
		if terrain:
			terrain.material_override = new_material


var _rebuild_queued = false
var _rebuilding = false

var _marcher: Marcher


func _ready():
	base_noise.changed.connect(queue_rebuild)
	additive_gradient.changed.connect(queue_rebuild)
	multiplicative_gradient.changed.connect(queue_rebuild)
	_rebuild_queued = true


func _process(delta):
	if _rebuilding:
		for i in range(1000):
			var done = _marcher.march()
			if done:
				_rebuilding = false
				highlight.change_mode(highlight.Mode.FADE_OUT)
				generate(_marcher._computed_verts, _marcher._computed_norms)
				break
		return

	if _rebuild_queued:
		rebuild()
		_rebuild_queued = false
		return


func queue_rebuild():
	_rebuild_queued = true


func rebuild():
	print("Rebuilding")
	highlight.change_mode(highlight.Mode.ON)

	var params = MarchingCubesParams.new()
	params.size = size
	params.iso_level = iso_level
	params.base_noise = base_noise

	params.additive_gradient = additive_gradient
	params.multiplicative_gradient = multiplicative_gradient

	_marcher = Marcher.new()
	_marcher.params = params
	_rebuilding = true

	# TODO - make the marcher run on a thread so we can just kick it off and subscribe to it when it's done

	if highlight:
		highlight.mesh.size = size
		highlight.transform.origin = Vector3(size) / 2


func generate(verts: PackedVector3Array, normals: PackedVector3Array):
	var num_triangles = len(verts) / 3

	print("Generating mesh from ", num_triangles, " triangles")

	if len(verts) > 0:
		var mesh_data = []
		mesh_data.resize(Mesh.ARRAY_MAX)
		mesh_data[Mesh.ARRAY_VERTEX] = verts
		mesh_data[Mesh.ARRAY_NORMAL] = normals
		if terrain.mesh:
			terrain.mesh.clear_surfaces()
		else:
			terrain.mesh = ArrayMesh.new()
			terrain.material_override = material_override
		terrain.mesh.clear_blend_shapes()
		terrain.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)
