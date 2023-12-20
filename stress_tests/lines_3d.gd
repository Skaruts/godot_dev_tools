extends Node3D



func _ready() -> void:
	# you can optionally turn things on at startup
	DevTools.enable_info()
	DevTools.enable_drawing()


func _process(delta: float) -> void:
	DevTools.print("fps", Engine.get_frames_per_second())
	DevTools3D.draw_sphere(true, Vector3.ZERO, 1, Color.RED)
	var t := Time.get_ticks_msec()

	var num_lines := 100
	DevTools.print("num_lines", num_lines)
	# DevTools.bm(name, func, smoothing=15, precision=4, time_units=DevTools.SEC)
	DevTools.print_bm(str(_process), func() -> void:
		for i in num_lines:
			var pos := Vector3(cos((t+i*i)*0.001), 0, sin((t+i*i)*0.001))
			DevTools3D.draw_line(pos, pos+Vector3.UP, Color.GREEN, 3)

		#DevTools3D.draw_line(Vector3(0, 0, 0), Vector3(0, 1, 0), Color.GREEN, 10)

	, {units=DevTools.MSEC})
