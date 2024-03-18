extends Node

const Params = preload("res://marching_cubes/models/params.gd")


class MarchingCubesNoise:
	var data: Array
	var size: Vector3i
	
	func GetNoise3D(position: Vector3i) -> float:
		if position.y < 1:
			return 1.0
		elif position.x <= 0 or position.z <= 0 \
			or position.x >= size.x or position.z >= size.z or position.y >= size.y:
			return 0.0

		return data[position.y][position.x][position.z]


static func GenerateMarchingCubesNoise(params: Params.MarchingCubesParams, base_noise: NoiseTexture2D) -> MarchingCubesNoise:
	var noise := MarchingCubesNoise.new()
	noise.size = params.size

	# initialize data matrix
	noise.data.resize(params.size.y)
	for y in range(params.size.y):
		noise.data[y] = Array()
		noise.data[y].resize(params.size.x)
		for x in range(params.size.x):
			noise.data[y][x] = Array()
			noise.data[y][x].resize(params.size.z)

	# populate the middle plane
	for x in range(params.size.x):
		for z in range(params.size.z):
			noise.data[params.sea_level][x][z] = (base_noise.noise.get_noise_2d(x, z) + 1.0) / 2.0

	# populate lower layers
	for y in range(params.sea_level-1, -1, -1):
		for x in range(params.size.x):
			for z in range(params.size.z):
				noise.data[y][x][z] = noise.data[y+1][x][z] \
					* params.lower_level_multiplicative_coefficient \
					+ params.lower_level_additive_coefficient # \
					# + (params.sea_level - y) * 0.01

	# populate higher layers
	for y in range(params.sea_level, params.size.y, 1):
		for x in range(params.size.x):
			for z in range(params.size.z):
				noise.data[y][x][z] = noise.data[y-1][x][z] \
					* params.higher_level_multiplicative_coefficient \
					+ params.higher_level_additive_coefficient # \
					# + (params.sea_level - y - 1) * 0.01

	return noise
