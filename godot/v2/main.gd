extends Node3D

signal data_loaded(triangles: Array)

const RAY_LENGTH = 1000
const check_time_interval_sec = 5
const TRIANGLES_FILE = "res://out.json"

var last_md5

const SCALE = 1.0


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
			"a": Vector3(d.A.X * SCALE, d.A.Y * SCALE, d.A.Z * SCALE),
			"b": Vector3(d.B.X * SCALE, d.B.Y * SCALE, d.B.Z * SCALE),
			"c": Vector3(d.C.X * SCALE, d.C.Y * SCALE, d.C.Z * SCALE),
			"n": Vector3(d.Normal.X * SCALE, d.Normal.Y * SCALE, d.Normal.Z * SCALE),
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


#func _physics_process(delta):
	#if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		#return
#
	#var space_state = get_world_3d().direct_space_state
	#var cam = $base/camera
	#var mousepos = get_viewport().get_mouse_position()
#
	#var origin = cam.project_ray_origin(mousepos)
	#var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	#var query = PhysicsRayQueryParameters3D.create(origin, end)
	#query.collide_with_areas = true
#
	#var result = space_state.intersect_ray(query)
	#if "position" in result:
		#print(result["position"])
