extends Node
class_name Marcher

var params: MarchingCubesParams

var _cursor: Vector3
var _computed_verts: PackedVector3Array
var _computed_norms: PackedVector3Array

var resolution := 1.0 # TODO - how make work for low res? (< 1.0)

func march() -> bool:
	var corners := [
		_evaluate(_cursor + resolution * Vector3(0, 0, 0)),
		_evaluate(_cursor + resolution * Vector3(1, 0, 0)),
		_evaluate(_cursor + resolution * Vector3(1, 0, 1)),
		_evaluate(_cursor + resolution * Vector3(0, 0, 1)),
		_evaluate(_cursor + resolution * Vector3(0, 1, 0)),
		_evaluate(_cursor + resolution * Vector3(1, 1, 0)),
		_evaluate(_cursor + resolution * Vector3(1, 1, 1)),
		_evaluate(_cursor + resolution * Vector3(0, 1, 1)),
	]

	var index := _cube_index_from_corners(corners)
	var offset = MarchingCubesTables.offsets[index]
	var length = MarchingCubesTables.lengths[index]

	for i in range(0, length, 3):
		_create_triangle(i, offset, corners)

	return _increment_cursor()


func _evaluate(position: Vector3i) -> Vector4:
	return Vector4(
		position.x,
		position.y,
		position.z,
		params.get_noise_3d(position)
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


func _create_triangle(index: int, offset: int, corners: Array):
	var v0 = MarchingCubesTables.lookup[offset + index + 0]
	var v1 = MarchingCubesTables.lookup[offset + index + 1]
	var v2 = MarchingCubesTables.lookup[offset + index + 2]

	var a0 = MarchingCubesTables.corners_a[v0]
	var b0 = MarchingCubesTables.corners_b[v0]

	var a1 = MarchingCubesTables.corners_a[v1]
	var b1 = MarchingCubesTables.corners_b[v1]

	var a2 = MarchingCubesTables.corners_a[v2]
	var b2 = MarchingCubesTables.corners_b[v2]

	# Calculate vertex positions
	var a = _interpolate_verts(corners[a0], corners[b0])
	var b = _interpolate_verts(corners[a1], corners[b1])
	var c = _interpolate_verts(corners[a2], corners[b2])

	var n = -(b - a).cross(c - a).normalized()

	_computed_verts.append(a)
	_computed_verts.append(b)
	_computed_verts.append(c)

	_computed_norms.append(n)
	_computed_norms.append(n)
	_computed_norms.append(n)


func _interpolate_verts(v1: Vector4, v2: Vector4) -> Vector3:
	var t = (params.iso_level - v1.w) / (v2.w - v1.w)
	var resolutionult_v4 = v1 + t * (v2 - v1)
	return Vector3(resolutionult_v4.x, resolutionult_v4.y, resolutionult_v4.z)


func _increment_cursor():
	_cursor.x += resolution
	if _cursor.x < params.size.x:
		return false

	_cursor.x = 0
	_cursor.z += resolution
	if _cursor.z < params.size.z:
		return false

	_cursor.z = 0
	_cursor.y += resolution
	return _cursor.y >= params.size.y
