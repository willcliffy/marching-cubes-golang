extends Node3D

signal data_loaded(triangles: Array)

const check_time_interval_sec = 5
const TRIANGLES_FILE = "res://out.json"

var last_md5


func _process(_delta):
	var md5 = FileAccess.get_md5(TRIANGLES_FILE)
	if md5 != last_md5:
		reload()
		last_md5 = md5


func reload():
	var data = load_json(TRIANGLES_FILE)
	if not data:
		return

	var triangles = []
	for d in data:
		triangles.append({
			"a": Vector3(d.A.X, d.A.Y, d.A.Z),
			"b": Vector3(d.B.X, d.B.Y, d.B.Z),
			"c": Vector3(d.C.X, d.C.Y, d.C.Z),
			"n": Vector3(d.Normal.X, d.Normal.Y, d.Normal.Z),
		})
	
	print("reload. ", len(triangles))
	data_loaded.emit(triangles)


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

