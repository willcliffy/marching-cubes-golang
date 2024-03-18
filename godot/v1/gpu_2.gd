extends Node


class Chunk extends Node3D:
	var coord: Vector3i
	var mesh: MeshInstance3D


# Const params
const num_points_per_axis: int = 30
const thread_group_size: int = 8
const bounds_size: float = 1.0
const num_chunks: Vector3i = Vector3i(2, 1, 2)

# Derived consts
const num_points: int = num_points_per_axis * num_points_per_axis * num_points_per_axis
const num_voxels_per_axis: int = num_points_per_axis - 1

const num_voxels: int = num_voxels_per_axis * num_voxels_per_axis * num_voxels_per_axis;
const max_triangle_count: int = 5 * num_voxels

const num_threads_per_axis = ceili(num_voxels_per_axis / thread_group_size)
const point_spacing = bounds_size / num_voxels_per_axis

# Class members

## General
var update_queued: bool = false
var chunks: Array = []

## Compute Shader
var rendering_device: RenderingDevice

var triangle_buffer_rid: RID
var triangle_buffer_bind_index: int = 0

var points_buffer_rid: RID
var points_buffer_bind_index: int = 0


func _ready():
	rendering_device = RenderingServer.create_local_rendering_device()

	create_buffers()
	# init_chunks()
	var chunk = Chunk.new()
	chunks.append(chunk)


func _process(delta):
	if update_queued:
		for chunk in chunks:
			update_chunk_mesh(chunk)
		update_queued = false


func create_buffers():
	var triangle_buffer_data = PackedFloat32Array()
	triangle_buffer_data.resize(max_triangle_count)
	var triangle_buffer_bytes = triangle_buffer_data.to_byte_array()
	triangle_buffer_rid = rendering_device.storage_buffer_create(triangle_buffer_bytes.size(), triangle_buffer_bytes)
	var triangle_buffer_uniform = RDUniform.new()
	triangle_buffer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	triangle_buffer_uniform.binding = triangle_buffer_bind_index
	triangle_buffer_uniform.add_id(triangle_buffer_rid)

	var points_buffer_data = PackedFloat32Array()
	points_buffer_data.resize(num_points)
	var points_buffer_bytes = points_buffer_data.to_byte_array()
	points_buffer_rid = rendering_device.storage_buffer_create(points_buffer_bytes.size(), points_buffer_bytes)
	var points_buffer_uniform = RDUniform.new()
	points_buffer_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	points_buffer_uniform.binding = points_buffer_bind_index
	points_buffer_uniform.add_id(points_buffer_rid)


	# 	triangleBuffer = new ComputeBuffer (maxTriangleCount, sizeof (float) * 3 * 3, ComputeBufferType.Append);
	# 	pointsBuffer = new ComputeBuffer (numPoints, sizeof (float) * 4);
	# 	triCountBuffer = new ComputeBuffer (1, sizeof (int), ComputeBufferType.Raw);


func update_chunk_mesh(chunk: Chunk):
	var coord = chunk.coord
	var center = center_from_coord(coord)
	var world_bounds = Vector3(num_chunks) * bounds_size

	# DensityGenerator.generate(pointsBuffer, numPointsPerAxis, boundsSize, worldBounds, centre, offset, pointSpacing)

	# triangleBuffer.SetCounterValue (0);
	# shader.SetBuffer (0, "points", pointsBuffer);
	# shader.SetBuffer (0, "triangles", triangleBuffer);
	# shader.SetInt ("numPointsPerAxis", numPointsPerAxis);
	# shader.SetFloat ("isoLevel", isoLevel);

	# shader.Dispatch (0, numThreadsPerAxis, numThreadsPerAxis, numThreadsPerAxis);

	# // Get number of triangles in the triangle buffer
	# ComputeBuffer.CopyCount (triangleBuffer, triCountBuffer, 0);
	# int[] triCountArray = { 0 };
	# triCountBuffer.GetData (triCountArray);
	# int numTris = triCountArray[0];

	# // Get triangle data from shader
	# Triangle[] tris = new Triangle[numTris];
	# triangleBuffer.GetData (tris, 0, 0, numTris);

	# Mesh mesh = chunk.mesh;
	# mesh.Clear ();

	# var vertices = new Vector3[numTris * 3];
	# var meshTriangles = new int[numTris * 3];

	# for (int i = 0; i < numTris; i++) {
	# 	for (int j = 0; j < 3; j++) {
	# 		meshTriangles[i * 3 + j] = i * 3 + j;
	# 		vertices[i * 3 + j] = tris[i][j];
	# 	}
	# }
	# mesh.vertices = vertices;
	# mesh.triangles = meshTriangles;

	# mesh.RecalculateNormals ();

func center_from_coord(coord: Vector3i):
	pass
