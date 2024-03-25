extends Resource
class_name MarchingCubesParams

@export var size: Vector3i
@export var iso_level: float

@export var base_noise: Noise
@export var additive_gradient: Curve
@export var multiplicative_gradient: Curve

@export var close_faces: bool = true

func get_noise_3d(position: Vector3) -> float:
	var y_normalized = position.y / float(size.y)

	var sample = self.base_noise.get_noise_2d(position.x, position.z)
	sample += self.additive_gradient.sample(y_normalized)
	sample *= self.multiplicative_gradient.sample(y_normalized)

	# TODO - this works for now since position is relative to the shape space
	# i.e. we always start position at 0, 0, 0 and have it go to `size`
	if close_faces:
		if position.x == 0 or position.x >= size.x - 1 \
			or position.z == 0 or position.z >= size.z - 1 \
			or position.y >= size.y - 1:
			return 0.0
		elif position.y == 0:
			return 1.0

	return sample
