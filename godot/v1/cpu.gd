extends Node

@onready var noise: NoiseTexture3D = preload("res://terrain_noise.tres")


signal compute_completed(data: Array)


const ENABLED: bool = true

const cornerIndexAFromEdge = [0, 1, 2, 3, 4, 5, 6, 7, 0, 1, 2, 3]
const cornerIndexBFromEdge = [1, 2, 3, 0, 5, 6, 7, 4, 4, 5, 6, 7]

const offsets = [0, 0, 3, 6, 12, 15, 21, 27, 36, 39, 45, 51, 60, 66, 75, 84, 90, 93, 99, 105, 114, 120, 129, 138, 150, 156, 165, 174, 186, 195, 207, 219, 228, 231, 237, 243, 252, 258, 267, 276, 288, 294, 303, 312, 324, 333, 345, 357, 366, 372, 381, 390, 396, 405, 417, 429, 438, 447, 459, 471, 480, 492, 507, 522, 528, 531, 537, 543, 552, 558, 567, 576, 588, 594, 603, 612, 624, 633, 645, 657, 666, 672, 681, 690, 702, 711, 723, 735, 750, 759, 771, 783, 798, 810, 825, 840, 852, 858, 867, 876, 888, 897, 909, 915, 924, 933, 945, 957, 972, 984, 999, 1008, 1014, 1023, 1035, 1047, 1056, 1068, 1083, 1092, 1098, 1110, 1125, 1140, 1152, 1167, 1173, 1185, 1188, 1191, 1197, 1203, 1212, 1218, 1227, 1236, 1248, 1254, 1263, 1272, 1284, 1293, 1305, 1317, 1326, 1332, 1341, 1350, 1362, 1371, 1383, 1395, 1410, 1419, 1425, 1437, 1446, 1458, 1467, 1482, 1488, 1494, 1503, 1512, 1524, 1533, 1545, 1557, 1572, 1581, 1593, 1605, 1620, 1632, 1647, 1662, 1674, 1683, 1695, 1707, 1716, 1728, 1743, 1758, 1770, 1782, 1791, 1806, 1812, 1827, 1839, 1845, 1848, 1854, 1863, 1872, 1884, 1893, 1905, 1917, 1932, 1941, 1953, 1965, 1980, 1986, 1995, 2004, 2010, 2019, 2031, 2043, 2058, 2070, 2085, 2100, 2106, 2118, 2127, 2142, 2154, 2163, 2169, 2181, 2184, 2193, 2205, 2217, 2232, 2244, 2259, 2268, 2280, 2292, 2307, 2322, 2328, 2337, 2349, 2355, 2358, 2364, 2373, 2382, 2388, 2397, 2409, 2415, 2418, 2427, 2433, 2445, 2448, 2454, 2457, 2460]
const lengths = [0, 3, 3, 6, 3, 6, 6, 9, 3, 6, 6, 9, 6, 9, 9, 6, 3, 6, 6, 9, 6, 9, 9, 12, 6, 9, 9, 12, 9, 12, 12, 9, 3, 6, 6, 9, 6, 9, 9, 12, 6, 9, 9, 12, 9, 12, 12, 9, 6, 9, 9, 6, 9, 12, 12, 9, 9, 12, 12, 9, 12, 15, 15, 6, 3, 6, 6, 9, 6, 9, 9, 12, 6, 9, 9, 12, 9, 12, 12, 9, 6, 9, 9, 12, 9, 12, 12, 15, 9, 12, 12, 15, 12, 15, 15, 12, 6, 9, 9, 12, 9, 12, 6, 9, 9, 12, 12, 15, 12, 15, 9, 6, 9, 12, 12, 9, 12, 15, 9, 6, 12, 15, 15, 12, 15, 6, 12, 3, 3, 6, 6, 9, 6, 9, 9, 12, 6, 9, 9, 12, 9, 12, 12, 9, 6, 9, 9, 12, 9, 12, 12, 15, 9, 6, 12, 9, 12, 9, 15, 6, 6, 9, 9, 12, 9, 12, 12, 15, 9, 12, 12, 15, 12, 15, 15, 12, 9, 12, 12, 9, 12, 15, 15, 12, 12, 9, 15, 6, 15, 12, 6, 3, 6, 9, 9, 12, 9, 12, 12, 15, 9, 12, 12, 15, 6, 9, 9, 6, 9, 12, 12, 15, 12, 15, 15, 6, 12, 9, 15, 12, 9, 6, 12, 3, 9, 12, 12, 15, 12, 15, 9, 12, 12, 15, 15, 6, 9, 12, 6, 3, 6, 9, 9, 6, 9, 12, 6, 3, 9, 6, 12, 3, 6, 3, 3, 0]



class Params:
	var lut: Array

	var size: Vector3 = Vector3(20, 10, 20)
	var iso_level: float = 0.6

	const resolution : int = 1024
	const work_group_size : int = 8
	const num_voxels_per_axis : int = work_group_size * resolution

	var scale : float = 1


var cursor: Vector3 = Vector3.ZERO

var params: Params

var computed = []

var done: bool = false


func _ready():
	if not ENABLED:
		set_process(false)
		return

	params = Params.new()
	params.lut = load_lut("res://marching_cubes_lookup.txt")


func _process(_delta):
	if done: return

	for _j in range(100):
		var corners = [
			evaluate(cursor + Vector3(0, 0, 0)),
			evaluate(cursor + Vector3(1, 0, 0)),
			evaluate(cursor + Vector3(1, 0, 1)),
			evaluate(cursor + Vector3(0, 0, 1)),
			evaluate(cursor + Vector3(0, 1, 0)),
			evaluate(cursor + Vector3(1, 1, 0)),
			evaluate(cursor + Vector3(1, 1, 1)),
			evaluate(cursor + Vector3(0, 1, 1))
		]

		var index = cube_index_from_postion(corners)
		var offset = offsets[index]
		var num_indicies = lengths[index]

		for i in range(0, num_indicies, 3):
			computed.append(create_triangle(i, offset, corners))

		#if len(computed) > 100:
			#compute_completed.emit(computed)
			#computed = []

		done = increment_cursor()
		if done:
			break

	if done: compute_completed.emit(computed)


func cube_index_from_postion(corners: Array) -> int:
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


func evaluate(position: Vector3) -> Vector4:
	# return Vector4(position.x, position.y, position.z, randf_range(0, 2))

	var cellSize = 1.0 / params.num_voxels_per_axis * params.scale
	var cx = int(position.x / cellSize + 0.5 * sign(position.x)) * cellSize
	var cy = int(position.y / cellSize + 0.5 * sign(position.y)) * cellSize
	var cz = int(position.z / cellSize + 0.5 * sign(position.z)) * cellSize
	var centreSnapped = Vector3(cx, cy, cz)

	var posNorm = position / (params.num_voxels_per_axis * Vector3.ONE)

	var world_pos = posNorm * params.scale + centreSnapped

	var density = custom_noise(world_pos)

	return Vector4(world_pos.x, world_pos.y, world_pos.z, density)


func create_triangle(i: int, offset: int, corners: Array) -> Models.Triangle:
	var v0 = params.lut[offset + i + 0]
	var v1 = params.lut[offset + i + 1]
	var v2 = params.lut[offset + i + 2]

	var a0 = cornerIndexAFromEdge[v0]
	var b0 = cornerIndexBFromEdge[v0]

	var a1 = cornerIndexAFromEdge[v1]
	var b1 = cornerIndexBFromEdge[v1]

	var a2 = cornerIndexAFromEdge[v2]
	var b2 = cornerIndexBFromEdge[v2]

	# Calculate vertex positions
	var triangle := Models.Triangle.new()
	triangle.a = interpolate_verts(corners[a0], corners[b0])
	triangle.b = interpolate_verts(corners[a1], corners[b1])
	triangle.c = interpolate_verts(corners[a2], corners[b2])

	var ab := triangle.b - triangle.a
	var ac := triangle.c - triangle.a
	triangle.n = -ab.cross(ac).normalized()

	return triangle


func interpolate_verts(v1: Vector4, v2: Vector4) -> Vector3:
	var t = (params.iso_level - v1.w) / (v2.w - v1.w)
	return to_vector_3(v1 + t * (v2 - v1))


func increment_cursor() -> bool:
	cursor.x += 1
	if cursor.x >= params.size.x:
		cursor.x = 0
		cursor.z += 1
		if cursor.z >= params.size.z:
			cursor.z = 0
			cursor.y += 1
			return cursor.y >= params.size.y

	return false


func load_lut(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var index_strings = text.split(',')
	var indices = []
	for s in index_strings:
		indices.append(int(s))

	return indices


func to_vector_3(v: Vector4) -> Vector3:
	return Vector3(v.x, v.y, v.z)


func custom_noise(pos: Vector3) -> float:
	var sample
	if pos.x < params.size.x * 0.05 or pos.x > params.size.x * 0.95:
		sample = 0.0
	elif pos.z < params.size.z * 0.05 or pos.z > params.size.z * 0.95:
		sample = 0.0
	elif pos.y < params.size.y * 0.05:
		sample = 0.0
	elif pos.y < params.size.y * 0.1:
		sample = 1.0
	else:
		sample = noise.noise.get_noise_3d(pos.x, pos.y, pos.z)

	return 0.5 * (sample + 1.0)
