extends Node

const Params = preload("res://marching_cubes/models/params.gd")
const Tables = preload("res://marching_cubes/models/tables.gd")
const Triangle = preload("res://marching_cubes/models/triangle.gd")
const CustomNoise = preload("res://marching_cubes/models/noise.gd")


class Marcher:
	var params: Params.MarchingCubesParams
	var tables: Tables.MarchingCubesTables
	var noise:  CustomNoise.MarchingCubesNoise

	var _cursor: Vector3
	var _computed: Array

	func march() -> bool:
		var corners := [
			_evaluate(_cursor + Vector3(0, 0, 0)),
			_evaluate(_cursor + Vector3(1, 0, 0)),
			_evaluate(_cursor + Vector3(1, 0, 1)),
			_evaluate(_cursor + Vector3(0, 0, 1)),
			_evaluate(_cursor + Vector3(0, 1, 0)),
			_evaluate(_cursor + Vector3(1, 1, 0)),
			_evaluate(_cursor + Vector3(1, 1, 1)),
			_evaluate(_cursor + Vector3(0, 1, 1)),
		]

		var index := _cube_index_from_corners(corners)
		var offset = tables.offsets[index]
		var length = tables.lengths[index]

		for i in range(0, length, 3):
			_computed.append(_create_triangle(i, offset, corners))

		return _increment_cursor()

	func _evaluate(position: Vector3i) -> Vector4:
		return Vector4(
			position.x,
			position.y,
			position.z,
			noise.GetNoise3D(position)
		)

	func _cube_index_from_corners(corners: Array) -> int:
		var index = 0
		if corners[0].w < params.iso_level:
			index += 1
		if corners[1].w < params.iso_level:
			index += 2
		if corners[2].w < params.iso_level:
			index += 4
		if corners[3].w < params.iso_level:
			index += 8
		if corners[4].w < params.iso_level:
			index += 16
		if corners[5].w < params.iso_level:
			index += 32
		if corners[6].w < params.iso_level:
			index += 64
		if corners[7].w < params.iso_level:
			index += 128
		return index

	func _create_triangle(index: int, offset: int, corners: Array) -> Triangle.Triangle:
		var v0 = tables.lookup[offset + index + 0]
		var v1 = tables.lookup[offset + index + 1]
		var v2 = tables.lookup[offset + index + 2]

		var a0 = tables.corners_a[v0]
		var b0 = tables.corners_b[v0]

		var a1 = tables.corners_a[v1]
		var b1 = tables.corners_b[v1]

		var a2 = tables.corners_a[v2]
		var b2 = tables.corners_b[v2]

		# Calculate vertex positions
		var triangle := Triangle.Triangle.new()
		triangle.a = _interpolate_verts(corners[a0], corners[b0])
		triangle.b = _interpolate_verts(corners[a1], corners[b1])
		triangle.c = _interpolate_verts(corners[a2], corners[b2])

		var ab := triangle.b - triangle.a
		var ac := triangle.c - triangle.a
		triangle.n = -ab.cross(ac).normalized()

		return triangle

	func _interpolate_verts(v1: Vector4, v2: Vector4) -> Vector3:
		var t = (params.iso_level - v1.w) / (v2.w - v1.w)
		var result_v4 = v1 + t * (v2 - v1)
		return Vector3(result_v4.x, result_v4.y, result_v4.z)

	func _increment_cursor():
		_cursor.x += 1
		if _cursor.x < params.size.x:
			return false
		_cursor.x = 0
		_cursor.z += 1
		if _cursor.z < params.size.z:
			return false
		_cursor.z = 0
		_cursor.y += 1
		return _cursor.y >= params.size.y
