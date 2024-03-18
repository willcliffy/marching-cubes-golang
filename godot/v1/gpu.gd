extends Node

signal compute_completed(data: Array)

@onready var shader_file: RDShaderFile = preload("res://marching_cubes.glsl")

const ENABLED: bool = false
const GPU_SYNC_DELAY_SECONDS: float = 0.005

@export var noise_scale: float = 0.5:
	set(new_noise_scale):
		noise_scale = new_noise_scale
		queue_compute()

@export var iso_level: float = 0.5:
	set(new_iso_level):
		iso_level = new_iso_level
		queue_compute()

@export var chunk_scale: float = 150:
	set(new_chunk_scale):
		chunk_scale = new_chunk_scale
		queue_compute()

@export var noise_offset: Vector3 = Vector3(10, 10, 10):
	set(new_noise_offset):
		noise_offset = new_noise_offset
		queue_compute()

const resolution : int = 4

const work_group_size : int = 8
const num_voxels_per_axis : int = work_group_size * resolution

# Thread I/O
var thread: Thread
var semaphore: Semaphore
var lock: Mutex

# Phone to the GPU
var rendering_device: RenderingDevice

# Resource IDs of things we need to keep track of
var shader_rid: RID
var pipeline_rid: RID
var uniform_set_rid: RID

var lookup_table_rid: RID
var lookup_table_bind_index: int = 0

var input_params_rid: RID
var input_params_bind_index: int = 1

var output_data_rid: RID
var output_data_bind_index: int = 2

var output_length_buffer_rid: RID
var output_length_bind_index = 3

# members
var compute_queued = false
var compute_processing = false
var stopped = false


func _ready():
	if not ENABLED:
		set_process(false)
		return

	semaphore = Semaphore.new()
	lock = Mutex.new()

	thread = Thread.new()
	thread.start(thread_run)

	rendering_device = RenderingServer.create_local_rendering_device()

	shader_rid = rendering_device.shader_create_from_spirv(shader_file.get_spirv())

	# lookup table
	var lut = load_lut("res://marching_cubes_lookup.txt")
	var lut_bytes = PackedInt32Array(lut).to_byte_array()
	lookup_table_rid = rendering_device.storage_buffer_create(lut_bytes.size(), lut_bytes)
	var lut_uniform = RDUniform.new()
	lut_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	lut_uniform.binding = lookup_table_bind_index
	lut_uniform.add_id(lookup_table_rid)

	# input params
	var input_params_bytes = PackedFloat32Array(get_params_array()).to_byte_array()
	input_params_rid = rendering_device.storage_buffer_create(input_params_bytes.size(), input_params_bytes)
	var input_params_uniform = RDUniform.new()
	input_params_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	input_params_uniform.binding = input_params_bind_index
	input_params_uniform.add_id(input_params_rid)

	# output buffer
	const max_tris_per_voxel : int = 5
	const max_triangles : int = max_tris_per_voxel * int(pow(num_voxels_per_axis, 3))
	const bytes_per_float : int = 4
	const floats_per_triangle : int = 4 * 3
	const bytes_per_triangle : int = floats_per_triangle * bytes_per_float
	const max_bytes : int = bytes_per_triangle * max_triangles
	var output := PackedFloat32Array()
	output.resize(max_bytes)
	var output_bytes = output.to_byte_array()

	output_data_rid = rendering_device.storage_buffer_create(output_bytes.size(), output_bytes)
	var output_uniform := RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_uniform.binding = output_data_bind_index
	output_uniform.add_id(output_data_rid)

	# output length
	var counter = [0]
	var counter_bytes = PackedInt32Array(counter).to_byte_array()
	output_length_buffer_rid = rendering_device.storage_buffer_create(counter_bytes.size(), counter_bytes)
	var output_length_uniform = RDUniform.new()
	output_length_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_length_uniform.binding = output_length_bind_index
	output_length_uniform.add_id(output_length_buffer_rid)

	var uniforms = [lut_uniform, input_params_uniform, output_uniform, output_length_uniform]
	uniform_set_rid = rendering_device.uniform_set_create(uniforms, shader_rid, 0)

	pipeline_rid = rendering_device.compute_pipeline_create(shader_rid)

	queue_compute()


func _process(_delta):
	if compute_queued and not compute_processing:
		compute_queued = false
		start_compute()


func queue_compute():
	compute_queued = true


func start_compute():
	if not lock.try_lock():
		print("failed to lock! probably already started compute")
		return

	compute_processing = true

	var input_params = PackedFloat32Array(get_params_array())
	var input_params_bytes = input_params.to_byte_array()
	rendering_device.buffer_update(input_params_rid, 0, input_params_bytes.size(), input_params_bytes)

	var counter = [0]
	var counter_bytes = PackedInt32Array(counter).to_byte_array()
	rendering_device.buffer_update(output_length_buffer_rid, 0, counter_bytes.size(), counter_bytes)


	# prepare the request to the rendering device
	var compute_list := rendering_device.compute_list_begin()
	rendering_device.compute_list_bind_compute_pipeline(compute_list, pipeline_rid)
	rendering_device.compute_list_bind_uniform_set(compute_list, uniform_set_rid, 0)
	rendering_device.compute_list_dispatch(compute_list, 8, 8, 8)
	rendering_device.compute_list_end()

	rendering_device.submit()

	# If the GPU isn't done by the time the semaphore posts, we may not sync all the data
	# From testing, deferring the semaphore post with `call_deferred` seems sufficient
	semaphore.post.call_deferred()
	# get_tree().create_timer(GPU_SYNC_DELAY_SECONDS).timeout.connect(semaphore.post)

	lock.unlock()


# Call only as deferred and from within thread!
func compute_complete(triangles):
	compute_completed.emit(triangles)


func thread_run():
	while true:
		semaphore.wait()

		lock.lock()
		var should_stop = stopped
		lock.unlock()

		if should_stop:
			return

		lock.lock()
		rendering_device.sync()

		var data_bytes := rendering_device.buffer_get_data(output_data_rid)
		var data := data_bytes.to_float32_array()

		var data_count_bytes = rendering_device.buffer_get_data(output_length_buffer_rid)
		var data_count := data_count_bytes.to_int32_array()[0]

		var triangles = process_mesh_data(data, data_count)

		compute_processing = false
		lock.unlock()
		compute_complete.call_deferred(triangles)


func process_mesh_data(data: Array, data_count: int) -> Array:
	var triangles := []

	for index in range(data_count):
		var i = index * 16
		var triangle = Models.Triangle.new()
		triangle.a = Vector3(data[i + 0], data[i + 1], data[i + 2])
		triangle.b = Vector3(data[i + 4], data[i + 5], data[i + 6])
		triangle.c = Vector3(data[i + 8], data[i + 9], data[i + 10])
		triangle.n = Vector3(data[i + 12], data[i + 13], data[i + 14])
		triangles.append(triangle)

	return triangles


func get_params_array():
	var params = []
	params.append(noise_scale)
	params.append(iso_level)
	params.append(float(num_voxels_per_axis))
	params.append(chunk_scale)
	#params.append(player.position.x)
	#params.append(player.position.y)
	#params.append(player.position.z)
	params.append(noise_offset.x)
	params.append(noise_offset.y)
	params.append(noise_offset.z)
	return params


func load_lut(file_path):
	var file = FileAccess.open(file_path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()

	var index_strings = text.split(',')
	var indices = []
	for s in index_strings:
		indices.append(int(s))
		
	return indices


func _exit_tree():
	if thread:
		lock.lock()
		stopped = true
		lock.unlock()
		semaphore.post()
		thread.wait_to_finish()


func _notification(type):
	if not ENABLED:
		return

	if type != NOTIFICATION_PREDELETE:
		return

	shader_rid = RID()

	rendering_device.free()
	rendering_device = null

	#rendering_device.free_rid(pipeline)
	#rendering_device.free_rid(triangle_buffer)
	#rendering_device.free_rid(params_buffer)
	#rendering_device.free_rid(counter_buffer);
	#rendering_device.free_rid(lut_buffer);
	#rendering_device.free_rid(shader)

	#pipeline = RID()
	#triangle_buffer = RID()
	#params_buffer = RID()
	#counter_buffer = RID()
	#lut_buffer = RID()
