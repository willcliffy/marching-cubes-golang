extends Node


class MarchingCubesParams:
	var size: Vector3i
	var sea_level: int

	var iso_level: float

	var lower_level_multiplicative_coefficient: float
	var lower_level_additive_coefficient: float
	var higher_level_multiplicative_coefficient: float
	var higher_level_additive_coefficient: float
