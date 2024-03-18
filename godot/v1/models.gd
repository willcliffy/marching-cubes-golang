extends Node


class Triangle:
	var a: Vector3
	var b: Vector3
	var c: Vector3
	var n: Vector3

	func _to_string():
		return "%s, %s, %s - %s" % [self.a, self.b, self.c, self.n]
