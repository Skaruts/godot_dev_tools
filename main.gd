extends Node3D

@onready var node := Node.new() # used in 'monitoring_data()'

func _ready() -> void:
	DevTools.enable_info()
	DevTools2D.enable()
	DevTools3D.enable()


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("foo", false):
		#print("FOOOOOOOOOO!")


func _process(delta: float) -> void:
	monitoring_data()
	drawing_in_3d()
	drawing_in_2d()



func monitoring_data() -> void:

	# DevTools.print(key value, float_precision=2)

	DevTools.print("fps", Engine.get_frames_per_second())
	DevTools.print("boolean thing", true)
	DevTools.print("string thing", "dssdasdasda")
	DevTools.print("float", PI)
	DevTools.print("more precise", TAU, 7)
	DevTools.print("just this key", "")
	DevTools.print("", "just this value")
	DevTools.print("", "")
	#DevTools.print(10, "")
	DevTools.print("array", [0,1,2,3,4,5,6,7,8,9])
	DevTools.print("dic", { "foo1"="bar", "foo2"="bar"})
	DevTools.print("vector3", Vector3(0.15416156, 10, 0.2))
	DevTools.print("object", node)
	DevTools.print("null value", null)

	# grouped prints don't need to be together like they are here
	DevTools.print_grouped("Some Group", "days", 7)
	DevTools.print_grouped("Some Group", "weekend", "too short")
	DevTools.print_grouped("Some Group", "is_raining", false)



func drawing_in_3d() -> void:
	# DevTools.draw_line( p1, p2, color, thickness=1.0 )
	DevTools3D.draw_line(Vector3(), Vector3(2, 2, -2), Color.RED, 1)

	# DevTools3D.draw_polyline( [points], color, thickness=1.0 )
	DevTools3D.draw_polyline( [
		Vector3(-1, 1, 3), Vector3(-1, 0, 3), Vector3(-1, 0, 2),
		Vector3(-1, 1, 2), Vector3( 0, 1, 2), Vector3( 0, 1, 3),
		Vector3( 0, 0, 3), Vector3( 0, 0, 2),
	], Color.DARK_ORANGE, 2 )

	# DevTools3D.draw_circle( filled?, position, axis/radius, color, thickness=1.0 )
	var t := Time.get_ticks_msec()*0.001
	DevTools3D.draw_circle(false, Vector3(), 1.0,  Vector3(0, cos(t), sin(t)), Color.RED,   2)
	DevTools3D.draw_circle(false, Vector3(), 0.75, Vector3(cos(t), 0, sin(t)), Color.GREEN, 2)
	DevTools3D.draw_circle(false, Vector3(), 0.5,  Vector3(cos(t), sin(t), 0), Color.BLUE,  2)

	# DevTools3D.draw_sphere( filled?, position, radius, color )
	DevTools3D.draw_sphere(true, Vector3(0, 0, 0), 20, Color.BLUE)

	# DevTools3D.draw_cube( filled?, position, size, color )
	DevTools3D.draw_cube(true, Vector3(0, 0, -2), 0.25, Color.RED)

	# DevTools3D.draw_text( position, text, color, size=1 )
	DevTools3D.draw_text(Vector3(0,1.5,0), "Text in 3D!", Color.GOLD, 2)

	# DevTools3D.draw_vector( position, direction, color, thickness=1.0 )
	DevTools3D.draw_vector(Vector3(0, 0, 1.5), Vector3(0, 2, 2), Color.GREEN, 3)
	DevTools3D.draw_vector(Vector3(0, 0, 1.5), Vector3.UP, Color.RED, 3)

	# DevTools3D.draw_origin( position, size, thickness=1.0 )
	DevTools3D.draw_origin(Vector3(), 1, 4)

	# DevTools3D.draw_aabb( position, size, color, thickness=1.0 )
	DevTools3D.draw_aabb(AABB(Vector3(0, 0, -2), Vector3(1, 1, 1)), Color.DARK_SALMON, 1)

	# DevTools3D.draw_transform( node_3d, size, local=false, thickness=1.0 )
	$CSGTorus3D.rotate_z(deg_to_rad(1))
	$CSGTorus3D.rotate_y(deg_to_rad(1))
	DevTools3D.draw_transform($CSGTorus3D, 0.5, false, 4)



func drawing_in_2d() -> void:
	# func draw_text(position, text, font_size, color, alignment=0)
	DevTools2D.draw_text(Vector2(500, 200), "Text in 2D!", 30, Color.ORANGE, true)

	# draw_text_outlined(position, text, font_size, out_size, color)
	DevTools2D.draw_text_outline(Vector2(500, 200), "Text in 2D!", 30, 2, Color.BLACK)

	# DevTools2D.draw_line( p1, p2, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_line(Vector2(100, 50), Vector2(200, 150), Color.DARK_GREEN, 4)

	# DevTools2D.draw_polyline( [points], color, thickness:=1.0, antialiased=false )
	DevTools2D.draw_polyline([
		Vector2(120,  70), Vector2(180,  70),
		Vector2(180, 130), Vector2(120, 130),
		Vector2(120,  90), Vector2(160,  90),
		Vector2(160, 110), Vector2(140, 110)
	], Color.BLUE_VIOLET, 4)

	# DevTools2D.draw_circle( filled?, center, axis/radius, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_circle(false, Vector2(300, 100), 50, Color.BLUE, 4)
	DevTools2D.draw_circle(true, Vector2(300, 100), 20, Color.RED)

	# DevTools2D.draw_rect( filled?, rect, color, thickness:=1.0, antialiased=false )
	DevTools2D.draw_rect(false, Rect2(400, 50, 100, 100), Color.GREEN_YELLOW, 4)
	DevTools2D.draw_rect(true, Rect2(425, 75, 50, 50), Color.GOLD)

	# DevTools2D.draw_arc(center, radius, start_angle, end_angle, point_count, color, thickness=1.0, antialiased=false)
	var t := Time.get_ticks_msec()*0.001
	DevTools2D.draw_arc(Vector2(600, 100), 50, 0,  TAU*cos(t), 32, Color.ORANGE_RED, 4)
	DevTools2D.draw_arc(Vector2(600, 100), 30, 0, -TAU*cos(t), 32, Color.ORANGE_RED, 4)

	# DevTools2D.draw_vector( position, direction, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_vector(Vector2(800, 100), (Vector2.RIGHT*75).rotated(PI* cos(t)), Color.DARK_SLATE_BLUE, 3)
	DevTools2D.draw_vector(Vector2(800, 100), (Vector2.LEFT*50).rotated(PI*sin(t)), Color.DARK_ORCHID, 3)

	$Icon.rotate(-PI*cos(t)*0.01)
	$Icon.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	$Icon/Icon2.rotate(-PI*cos(t)*0.01)
	$Icon/Icon2.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	DevTools2D.draw_transform($Icon, 75, false, 4)
	DevTools2D.draw_transform($Icon/Icon2, 75, true, 4)
	DevTools2D.draw_transform($Icon/Icon2, 40, false, 4)
	pass
