extends Node3D



func _ready() -> void:
	# you can optionally turn things on at startup
	debug.enable_info()
	debug.enable_drawing()


func _process(_delta: float) -> void:
	debug.print("fps", Engine.get_frames_per_second())
	debug3d.draw_sphere(Vector3.ZERO, 1, Color.RED, true)
	var t := Time.get_ticks_msec()

	var num_lines := 100
	debug.print("num_lines", num_lines)
	# debug.bm(name, func, smoothing=15, precision=4, time_units=debug.SEC)
	debug.print_bm(str(_process), func() -> void:
		for i in num_lines:
			var pos := Vector3(cos((t+i*i)*0.001), 0, sin((t+i*i)*0.001))
			debug3d.draw_line(pos, pos+Vector3.UP, Color.GREEN, 3)

		#debug3d.draw_line(Vector3(0, 0, 0), Vector3(0, 1, 0), Color.GREEN, 10)

	, {units=debug.MSEC})
