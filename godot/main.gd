extends Node3D


func _ready():
	var data = load_json("res://out.json")
	if not data:
		return

	#for d in data:
		#print(d)

	var triangles = []
	for d in data:
		triangles.append({
			"a": Vector3(d.A.X, d.A.Y, d.A.Z),
			"b": Vector3(d.B.X, d.B.Y, d.B.Z),
			"c": Vector3(d.C.X, d.C.Y, d.C.Z),
			"n": Vector3(d.Normal.X, d.Normal.Y, d.Normal.Z),
		})

	$terrain.generate(triangles)


func load_json(file_name: String):
	if not FileAccess.file_exists(file_name):
		print("File not found.")
		return

	var file = FileAccess.open(file_name, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()

	var proto_data = JSON.parse_string(json_text)
	if typeof(proto_data) != TYPE_ARRAY:
		print("Failed to parse JSON.")
		return

	return proto_data

