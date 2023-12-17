extends Node3D



@onready var node := Node.new()

func _ready() -> void:
	DebugTools.show_info()
	DebugTools.show_drawing()


func _process(delta: float) -> void:
	monitoring_data()
	drawing_in_3d()
	drawing_in_2d()

func monitoring_data() -> void:
	# DebugTools.print(key value, float_precision=2)
	DebugTools.print("fps", Engine.get_frames_per_second())
	DebugTools.print("boolean thing", true)
	DebugTools.print("string thing", "dssdasdasda")
	DebugTools.print("float", PI)
	DebugTools.print("more precise", TAU, 7)
	DebugTools.print("just this key", "")
	DebugTools.print("", "just this value")
	DebugTools.print("", "")
	#DebugTools.print(10, "")
	DebugTools.print("array", [0,1,2,3,4,5,6,7,8,9])
	DebugTools.print("dic", { "foo1"="bar", "foo2"="bar"})
	DebugTools.print("vector3", Vector3(0.15416156, 10, 0.2))
	DebugTools.print("object", node)
	DebugTools.print("null value", null)

	# grouped prints don't need to be together
	DebugTools.print_grouped("Some Group", "x", 10.5)
	DebugTools.print_grouped("Some Group", "days", 7)
	DebugTools.print_grouped("Some Group", "weekend", "too short")
	DebugTools.print_grouped("Some Group", "is_raining", false)



func drawing_in_3d() -> void:
	# DebugTools.draw_line(p1, p2, color, thickness=1)
	DebugTools.draw_line(Vector3(), Vector3(2, 2, -2), Color.RED, 1)

	# DebugTools.draw_ball(position, radius, color)
	DebugTools.draw_ball(Vector3(0, 0, 0), 20, Color.BLUE)

	# DebugTools.draw_vector(position, direction, color, thickness=1)
	DebugTools.draw_vector(Vector3(0, 0, 1.5), Vector3(0, 2, 2), Color.GREEN, 3)
	DebugTools.draw_vector(Vector3(0, 0, 1.5), Vector3.UP, Color.RED, 3)

	# DebugTools.draw_circle(position, axis/radius, color, thickness=1)
	var t := Time.get_ticks_msec()*0.001
	DebugTools.draw_circle(Vector3(), Vector4(0, cos(t), sin(t),  1.0),  Color.RED,   2)
	DebugTools.draw_circle(Vector3(), Vector4(cos(t), 0, sin(t),  0.75), Color.GREEN, 2)
	DebugTools.draw_circle(Vector3(), Vector4(cos(t), sin(t), 0,  0.5),  Color.BLUE,  2)

	# DebugTools.draw_origin(position, size, thickness=1)
	DebugTools.draw_origin(Vector3(), 1, 4)

	# DebugTools.draw_text(position, text, color, size=1)
	DebugTools.draw_text(Vector3(0,1.5,0), "Text in 3D!", Color.GOLD, 2)

	# DebugTools.draw_transform(node, size, local=false, thickness=1)
	$CSGTorus3D.rotate_z(deg_to_rad(1))
	$CSGTorus3D.rotate_y(deg_to_rad(1))
	DebugTools.draw_transform($CSGTorus3D, 0.5, false, 4)

	# DebugTools.draw_polyline(points, color, thickness=1)
	DebugTools.draw_polyline( [
		Vector3(-1, 1, 3), Vector3(-1, 0, 3), Vector3(-1, 0, 2),
		Vector3(-1, 1, 2), Vector3( 0, 1, 2), Vector3( 0, 1, 3),
		Vector3( 0, 0, 3), Vector3( 0, 0, 2),
	], Color.DARK_ORANGE, 2)

	# DebugTools.draw_box(position, size, color)
	DebugTools.draw_box(Vector3(0, 0, -2), 0.25, Color.RED)

	# DebugTools.draw_aabb(position, size, color, thickness=1, draw_faces=false)
	DebugTools.draw_aabb(Vector3(0, 0, -2), Vector3(1, 1, 1), Color.DARK_SALMON, 1, false)


func drawing_in_2d() -> void:
	# DebugTools.draw_line(p1, p2, color, thickness=1)
	DebugTools.draw_line(Vector2(100, 50), Vector2(200, 150), Color.DARK_GREEN, 3)

	# DebugTools.draw_ball(position, radius, color)
	DebugTools.draw_ball(Vector2(300, 100), 20, Color.RED)
#
	## DebugTools.draw_vector(position, direction, color, thickness=1)
	#DebugTools.draw_vector(Vector3(0, 0, 1.5), Vector3(0, 2, 2), Color.GREEN, 3)
	#DebugTools.draw_vector(Vector3(0, 0, 1.5), Vector3.UP, Color.RED, 3)
#
	# DebugTools.draw_circle(position, axis/radius, color, thickness=1)
	DebugTools.draw_circle(Vector2(300, 100), 50, Color.BLUE, 4)

	#DebugTools.draw_circle(Vector3(), Vector4(cos(t), 0, sin(t),  0.75), Color.GREEN, 2)
	#DebugTools.draw_circle(Vector3(), Vector4(cos(t), sin(t), 0,  0.5),  Color.BLUE,  2)
