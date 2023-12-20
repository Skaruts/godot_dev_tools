extends Node3D




# dummy class for demonstration purposes
class Foo:
	var name := "Foo"
	var x:int
	var y:int
	var z:int
	func _init(_x:int, _y:int, _z:int) -> void:
		x = _x
		y = _y
		z = _z
	func _to_string() -> String:
		return "(%s, %s, %s)" % [x, y, z]

@onready var foo := Foo.new(10, 20, 30)



func _ready() -> void:
	# you can optionally turn things on at startup
	DevTools.enable_info()
	DevTools.enable_drawing()


	# this will register the listed properties of 'foo', which will
	# be displayed and updated automatically forever, or until you
	# call DevTools.unregister().
	DevTools.register(foo, ["x", "y"])

	# NOTE: register() should be called only once, in _init, _ready
	# or _enter_tree

	# NOTE: objects must call DevTools.unregister() before being freed.


func _process(_delta: float) -> void:

	# example benchmark using a lambda

	# DevTools.print_bm(name, func, options)
	DevTools.print_bm("DevTools bm", func() -> void:
		monitoring_data()
		drawing_in_3d()
		drawing_in_2d()
		draw_help_info()
	, {smoothing=200, precision=2, units=DevTools.MSEC} ) # <-- NOTE: these arguments are all optional



func monitoring_data() -> void:

	# Example printing

	# DevTools.print(key value, float_precision=2)
	DevTools.print("fps", Engine.get_frames_per_second())
	DevTools.print("boolean thing", true)
	#DevTools.print("very long string that never ends", "very long string that never ends")
	DevTools.print("string thing", "dssdasdasda")
	DevTools.print("float", PI)
	DevTools.print("more precise", TAU, 7)
	DevTools.print("just this key", "")
	DevTools.print("", "just this value")
	DevTools.print("", "")
	#DevTools.print(10, "")
	DevTools.print("array", [0,1,2,3,4,5,6,7,8,9])
	DevTools.print("dic", {"foo1"="bar", "foo2"="bar"})
	DevTools.print("vector3", Vector3(0.15416156, 10, 0.2))
	DevTools.print("object", foo)
	DevTools.print("null value", null)

	# 'print_prop()' will attach the key/value to the node's property group
	# along with the ones already registered in _ready().
	DevTools.print_prop(foo, "z", foo.z)

	# grouped prints don't need to be together like they are here
	DevTools.print_grouped("Some Group", "days", 7)
	DevTools.print_grouped("Some Group", "weekend", "too short")
	DevTools.print_grouped("Some Group", "is_raining", false)



func drawing_in_2d() -> void:

	# Example 2D drawing

	# func draw_text(position, text, font_size, color, alignment=0)
	DevTools2D.draw_text(Vector2(250, 250), "Text without outline", 30, Color.ORANGE, true)
	# draw_text_outlined(position, text, font_size, out_size, color)
	DevTools2D.draw_text_outline(Vector2(650, 250), "Outline without text", 30, 3, Color.BLACK)

	# you can also
	DevTools2D.draw_text(Vector2(120, 200), "Lines", 25, Color.WHITE, true, 10)
	# DevTools2D.draw_line( p1, p2, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_line(Vector2(100, 50), Vector2(200, 150), Color.DARK_GREEN, 4)

	# DevTools2D.draw_polyline( [points], color, thickness:=1.0, antialiased=false )
	DevTools2D.draw_polyline([
		Vector2(120,  70), Vector2(180,  70),
		Vector2(180, 130), Vector2(120, 130),
		Vector2(120,  90), Vector2(160,  90),
		Vector2(160, 110), Vector2(140, 110)
	], Color.BLUE_VIOLET, 4)


	DevTools2D.draw_text(Vector2(260, 200), "Circles", 25, Color.WHITE, true, 10)
	# DevTools2D.draw_circle( filled?, center, axis/radius, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_circle(false, Vector2(300, 100), 50, Color.BLUE, 4)
	DevTools2D.draw_circle(true, Vector2(300, 100), 20, Color.RED)


	DevTools2D.draw_text(Vector2(420, 200), "Rects", 25, Color.WHITE, true, 10)
	# DevTools2D.draw_rect( filled?, rect, color, thickness:=1.0, antialiased=false )
	DevTools2D.draw_rect(false, Rect2(400, 50, 100, 100), Color.GREEN_YELLOW, 4)
	DevTools2D.draw_rect(true, Rect2(425, 75, 50, 50), Color.GOLD)


	DevTools2D.draw_text(Vector2(575, 200), "Arcs", 25, Color.WHITE, true, 10)
	# DevTools2D.draw_arc(center, radius, start_angle, end_angle, point_count, color, thickness=1.0, antialiased=false)
	var t := Time.get_ticks_msec()*0.001
	DevTools2D.draw_arc(Vector2(600, 100), 50, 0,  TAU*cos(t), 32, Color.ORANGE_RED, 4)
	DevTools2D.draw_arc(Vector2(600, 100), 30, 0, -TAU*cos(t), 32, Color.ORANGE_RED, 4)


	DevTools2D.draw_text(Vector2(750, 200), "Vectors", 25, Color.WHITE, true, 10)
	# DevTools2D.draw_vector( position, direction, color, thickness=1.0, antialiased=false )
	DevTools2D.draw_vector(Vector2(800, 100), (Vector2.RIGHT*75).rotated(PI* cos(t)), Color.DARK_SLATE_BLUE, 3)
	DevTools2D.draw_vector(Vector2(800, 100), (Vector2.LEFT*50).rotated(PI*sin(t)), Color.DARK_ORCHID, 3)


	DevTools2D.draw_text(Vector2(950, 200), "Transforms", 25, Color.WHITE, true, 10)
	$Icon.rotate(-PI*cos(t)*0.01)
	$Icon.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	$Icon/Icon2.rotate(-PI*cos(t)*0.01)
	$Icon/Icon2.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	DevTools2D.draw_transform($Icon, 75, false, 4)
	DevTools2D.draw_transform($Icon/Icon2, 75, true, 4)
	DevTools2D.draw_transform($Icon/Icon2, 40, false, 4)

	pass


func drawing_in_3d() -> void:

	# Example 3D drawing

	var t := Time.get_ticks_msec()*0.001

	# DevTools3D.draw_text( position, text, color, size=1 )
	DevTools3D.draw_text(Vector3(0, 2.2, 0), "Lines", Color.GREEN_YELLOW, 1)
	# DevTools.draw_line( p1, p2, color, thickness=1.0 )
	DevTools3D.draw_line(Vector3(0, 2, -2), Vector3(0, 2, 2), Color.DARK_RED, 1)


	DevTools3D.draw_text(Vector3(-1, 1.2, 2.5), "Polylines", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_polyline( [points], color, thickness=1.0 )
	DevTools3D.draw_polyline( [
		Vector3(-1, 1, 3), Vector3(-1, 0, 3), Vector3(-1, 0, 2),
		Vector3(-1, 1, 2), Vector3( 0, 1, 2), Vector3( 0, 1, 3),
		Vector3( 0, 0, 3), Vector3( 0, 0, 2),
	], Color.DARK_ORANGE, 2 )


	DevTools3D.draw_text(Vector3(0, 1.2, 0), "Circles", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_circle( filled?, position, axis/radius, color, thickness=1.0 )

	DevTools3D.draw_circle(false, Vector3(), 1.0,  Vector3(0, cos(t), sin(t)), Color.RED,   2)
	DevTools3D.draw_circle(false, Vector3(), 0.75, Vector3(cos(t), 0, sin(t)), Color.GREEN, 2)
	DevTools3D.draw_circle(false, Vector3(), 0.5,  Vector3(cos(t), sin(t), 0), Color.BLUE,  2)


	DevTools3D.draw_text(Vector3(0, 0.2, -0.5), "Spheres", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_sphere( filled?, position, radius, color )
	DevTools3D.draw_sphere(true, Vector3(0, 0, 0), 0.3, Color.BLUE)


	DevTools3D.draw_text(Vector3(0, 0.3, -2.5), "Cubes", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_cube( filled?, position, size, color )
	DevTools3D.draw_cube(true, Vector3(0, 0, -2), 0.25, Color.DARK_RED)


	DevTools3D.draw_text(Vector3(0.75, 0.75, 2), "Vectors", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_vector( position, direction, color, thickness=1.0 )
	DevTools3D.draw_vector(Vector3(1, 0, 1.5), Vector3(0, 2*sin(t), 2*sin(t)), Color.GREEN, 3)
	DevTools3D.draw_vector(Vector3(0.5, 0, 1.5), Vector3.UP*cos(t), Color.DARK_RED, 3)


	DevTools3D.draw_text(Vector3(0, -0.2, 0.75), "Origins", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_origin( position, size, thickness=1.0 )
	DevTools3D.draw_origin(Vector3(), 1, 4)

	DevTools3D.draw_text(Vector3(0, 1.3, -1.75), "AABBs", Color.GREEN_YELLOW, 1)
	var pos := Vector3(0.1*cos(t), 0, -2+(0.1*sin(t)))
	var size := Vector3.ONE
	# DevTools3D.draw_aabb( position, size, color, thickness=1.0 )
	DevTools3D.draw_aabb(AABB(pos, size), Color.DARK_SALMON, 1)


	DevTools3D.draw_text(Vector3(0, 1.3, -4.5), "Transforms", Color.GREEN_YELLOW, 1)
	# DevTools3D.draw_transform( node_3d, size, local=false, thickness=1.0 )
	$CSGTorus3D.rotate_z(deg_to_rad(1))
	$CSGTorus3D.rotate_y(deg_to_rad(1))
	DevTools3D.draw_transform($CSGTorus3D, 0.5, false, 4)



func draw_help_info() -> void:
	var ws := DisplayServer.window_get_size()
	var font_size := 20

	var text1 := "Default keys: '\\' or '~' to toggle info   |   'ctrl' + '\\' or '~' to toggle drawing"
	var width1 := DevTools2D.get_text_size(text1, font_size).x
	DevTools2D.draw_text(Vector2(ws.x/2.0-width1/2.0, ws.y-50), text1, font_size, Color.WHITE, true, 10)

	var text2 := "Right-Mouse + WASD to fly around   |   Shift to speed up"
	var width2 := DevTools2D.get_text_size(text2, font_size).x
	DevTools2D.draw_text(Vector2(ws.x/2.0-width2/2.0, ws.y-15), text2, font_size, Color.WHITE, true, 10)
