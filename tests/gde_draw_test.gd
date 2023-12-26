extends Node3D



func _ready() -> void:
	Toolbox.monitoring_enable()
	Toolbox.drawing_enable()


func _process(_delta: float) -> void:
	Toolbox3D.draw_origin(Vector3(), 0.5)
	#Toolbox3D.draw_line2(Vector3(-1, 0, 0), Vector3(1, 0, 0), Color.DARK_RED, 2)
	#Toolbox3D.draw_line2(Vector3(-1, 0, 1), Vector3(1, 0, -1), Color.DARK_BLUE, 2)
	#Toolbox3D.draw_line2(Vector3(-2, 0, 2), Vector3(2, 0, -2), Color.DARK_GREEN, 2)
	#Toolbox3D.draw_line(Vector3(4, 0, -2), Vector3(2, 0, 0), Color.DARK_GREEN, 2)

	#Toolbox3D.draw_line(Vector3(4, 1, -2), Vector3(2, 1, 0), Color.DARK_BLUE,  1)
	Toolbox3D.draw_line(Vector3(4, 1, -2), Vector3(2, 1, 0), Color.DARK_BLUE, 1)

	# [X: (-0.707107, 0, -0.707107), Y: (0, 1, 0), Z: (0.707107, 0, -0.707107), O: (3, 1, -1)]
	# [X: (-0.707107, 0, -0.707107), Y: (0, 1, 0), Z: (0.707107, 0, -0.707107), O: (3, 1, -1)]
	# [X: (-1.414214, 0, -1.414214), Y: (0, 2, 0), Z: (2.014142, 0, -2.014142), O: (3, 1, -1)]

	# [X: (-0.574638, 0, -0.818408), Y: (0, 1, 0), Z: (0.818407, 0, -0.574638), O: (3, 1, -1)]
	# [X: (-0.707107, 0, -0.707107), Y: (0, 1, 0), Z: (0.707107, 0, -0.707107), O: (3, 1, -1)]
	# [X: (-1.414214, 0, -2.014142), Y: (0, 2, 0), Z: (1.414214, 0, -2.014142), O: (3, 1, -1)]



	#[X: (-0.707107, 0, -0.707107), Y: (0, 1, 0), Z: (0.707107, 0, -0.707107), O: (3, 1, -1)]
	#(-0.707107, 0, 0.707107)


	# gds transform: [X: (-1.414214, 0, -1.414214), Y: (0, 2, 0), Z: (2.014142, 0, -2.014142), O: (3, 1, -1)]
	# cpp transform: [X: (-1.414214, 0, -2.014142), Y: (0, 2, 0), Z: (1.414214, 0, -2.014142), O: (3, 1, -1)]



	#Toolbox3D.draw_line(Vector3(0, 0, -1), Vector3(0, 0, 1), Color.DARK_GREEN, 2)

	Toolbox3D.draw_polyline( [
		Vector3(-1, 1, 3), Vector3(-1, 0, 3), Vector3(-1, 0, 2),
		Vector3(-1, 1, 2), Vector3( 0, 1, 2), Vector3( 0, 1, 3),
		Vector3( 0, 0, 3), Vector3( 0, 0, 2),
	], Color.DARK_ORANGE, 2)

	Toolbox3D.draw_sphere(Vector3(0, 0.5, 0), 0.5, Color.BLACK, false, 1)
	#Toolbox3D.draw_sphere2(Vector3(0, 0.5, 0), 0.5, Color.BLACK, false, 1)
	#Toolbox3D.draw_sphere2(Vector3(0, 1.5, 0), 0.5, Color.BLACK, false, 1)
	#Toolbox3D.draw_sphere2(Vector3(0, 2.5, 0), 0.5, Color.BLACK, false, 1)
	#Toolbox3D.draw_sphere2(Vector3(0, 3.5, 0), 0.5, Color.BLACK, false, 1)

	#var num_lines := 17
	#var x:int = -floor(num_lines/2.0)
	#for i in num_lines:
		#Toolbox3D.draw_line(Vector3(x+i, 0, 1), Vector3(x+i, 0, -1), Color.DARK_RED, 2)

	Toolbox3D.draw_vector(Vector3(0,1,0), Vector3(0.7, 0.7, 0.7), Color.RED, 2)
	pass
