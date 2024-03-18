extends Node3D

@onready var camera = $camera

signal compute_done(triangles: Array)

const TABLES_FILE = preload("res://marching_cubes/tables.json")

const Tables = preload("res://marching_cubes/models/tables.gd")
const Params = preload("res://marching_cubes/models/params.gd")
const CustomNoise = preload("res://marching_cubes/models/noise.gd")

const Marcher = preload("res://marching_cubes/marching_cubes.gd")


@export_group("Marching Cubes Parameters")
@export
var size := Vector3i(100, 25, 100):
	set(new_value):
		size = new_value
		recalculation_queued = true

@export
var iso_level := 0.7:
	set(new_value):
		iso_level = new_value
		recalculation_queued = true

@export_range(0, 25, 1)
var sea_level = 5:
	set(new_value):
		sea_level = new_value
		recalculation_queued = true

@export_range(1.0, 10.0, 0.01)
var low_multiplicative_coefficient = 1.1:
	set(new_value):
		low_multiplicative_coefficient = new_value
		recalculation_queued = true

@export
var low_additive_coefficient = 0.0:
	set(new_value):
		low_additive_coefficient = new_value
		recalculation_queued = true

@export_range(0.0, 1.0, 0.01)
var high_multiplicative_coefficient = 0.9:
	set(new_value):
		high_multiplicative_coefficient = new_value
		recalculation_queued = true

@export
var high_additive_coefficient = 0.0:
	set(new_value):
		high_additive_coefficient = new_value
		recalculation_queued = true

@export_group("Base Noise Parameters")
@export
var noise_source := FastNoiseLite.new():
	set(new_value):
		noise_source = new_value
		recalculation_queued = true


var marcher: Marcher.Marcher
var done: bool

var tables: Tables.MarchingCubesTables

var recalculation_queued: bool

func _ready():
	tables = Tables.MarchingCubesTables.Load(TABLES_FILE)
	if tables == null:
		print("Failed to load tables. Exiting")
		return
	
	recalculation_queued = true
	
	noise_source.changed.connect(
		func(): 
			recalculation_queued = true
	)

	# TODO - hacky
	camera.transform.origin.x = size.x / 3.0
	camera.transform.origin.z = size.z / 3.0


func recalculate():
	print("recalculating")
	var params = Params.MarchingCubesParams.new()
	params.size = size
	params.sea_level = sea_level
	params.iso_level = iso_level
	params.lower_level_multiplicative_coefficient = low_multiplicative_coefficient
	params.lower_level_additive_coefficient = low_additive_coefficient
	params.higher_level_multiplicative_coefficient = high_multiplicative_coefficient
	params.higher_level_additive_coefficient = high_additive_coefficient
	
	var noise_texture = NoiseTexture2D.new()
	noise_texture.noise = noise_source

	var noise = CustomNoise.GenerateMarchingCubesNoise(
		params,
		noise_texture
	)

	marcher = Marcher.Marcher.new()
	marcher.params = params
	marcher.tables = tables
	marcher.noise = noise


func _process(_delta):
	if recalculation_queued:
		recalculate()
		done = false
		recalculation_queued = false
		return

	if done:
		return

	for i in range(10000):
		done = marcher.march()

		if done:
			compute_done.emit(marcher._computed)
