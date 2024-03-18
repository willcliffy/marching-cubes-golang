extends Node3D

@onready var MeshInstance: MeshInstance3D = $Mesh


func generate(data: Array):
	var num_triangles = len(data)
	var num_verts : int = num_triangles * 3

	print("in terrain, got ", num_triangles, " triangles")

	var verts = PackedVector3Array()
	var normals = PackedVector3Array()

	verts.resize(num_verts)
	normals.resize(num_verts)

	for i in range(num_triangles):
		var triangle = data[i]
		verts[i * 3 + 0] = triangle.a
		verts[i * 3 + 1] = triangle.b
		verts[i * 3 + 2] = triangle.c
		normals[i * 3 + 0] = triangle.n
		normals[i * 3 + 1] = triangle.n
		normals[i * 3 + 2] = triangle.n

	print("Num tris: ", num_triangles, " FPS: ", Engine.get_frames_per_second())

	if len(verts) > 0:
		var mesh_data = []
		mesh_data.resize(Mesh.ARRAY_MAX)
		mesh_data[Mesh.ARRAY_VERTEX] = verts
		mesh_data[Mesh.ARRAY_NORMAL] = normals
		# MeshInstance.mesh.clear_surfaces()
		MeshInstance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, mesh_data)

