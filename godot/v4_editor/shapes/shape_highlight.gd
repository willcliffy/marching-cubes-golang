@tool
extends MeshInstance3D

@export
var loading_color: Color = Color.DIM_GRAY

@export
var done_color: Color = Color.FOREST_GREEN

enum Mode {
	OFF,
	ON,
	FADE_OUT
}

var fade_out_duration = 1.0

var frequency = 0.5 # How fast the material pulses
var min_alpha = 0.10 # Minimum alpha value
var max_alpha = 0.50 # Maximum alpha value

var accumulated_time = 0.0 # Accumulate time based on delta

var mode: Mode


func _process(delta):
	if mode == Mode.OFF:
		return
	elif mode == Mode.ON:
		accumulated_time += delta
		var alpha = min_alpha + (max_alpha - min_alpha) * 0.5 * (1.0 + sin(accumulated_time * frequency * 2 * PI))
		material_override.albedo_color.a = alpha
	elif mode == Mode.FADE_OUT:
		accumulated_time += delta
		if accumulated_time > fade_out_duration:
			change_mode(Mode.OFF)
			return
		var alpha = 1.0 - (accumulated_time / fade_out_duration)
		material_override.albedo_color.a = alpha


func change_mode(new_mode: Mode):
	mode = new_mode

	if mode == Mode.OFF:
		material_override.albedo_color.a = 0.0
	elif mode == Mode.ON:
		accumulated_time = 0.0
		material_override.albedo_color = loading_color
	elif mode == Mode.FADE_OUT:
		accumulated_time = 0.0
		material_override.albedo_color = done_color
