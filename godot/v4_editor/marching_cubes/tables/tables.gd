@tool
extends Node

@export var offsets: Array
@export var lengths: Array
@export var corners_a: Array
@export var corners_b: Array
@export var lookup: Array


func _ready():
	var file = preload("./tables.json")
	offsets = file.data["offsets"]
	lengths = file.data["lengths"]
	corners_a = file.data["cornerA"]
	corners_b = file.data["cornerB"]
	lookup = file.data["lookup"]
