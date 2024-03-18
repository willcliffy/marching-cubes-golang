extends Node


class MarchingCubesTables:
	var offsets: Array
	var lengths: Array
	var corners_a: Array
	var corners_b: Array
	var lookup: Array

	static func Load(file: JSON) -> MarchingCubesTables:
		var tables = MarchingCubesTables.new()
		tables.offsets = file.data["offsets"]
		tables.lengths = file.data["lengths"]
		tables.corners_a = file.data["cornerA"]
		tables.corners_b = file.data["cornerB"]
		tables.lookup = file.data["lookup"]
		return tables
