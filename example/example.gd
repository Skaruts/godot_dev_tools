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
	#var g := DrawTool3D_GDE.new()
	#g.init()
	#print(g.width_factor)
	#g.width_factor = 1

	# you can optionally turn things on at startup
	debug.monitoring_enable()
	debug.drawing_enable()


	# this will register the listed properties of 'foo', which will
	# be displayed and updated automatically forever, or until you
	# call debug.unregister(foo).
	debug.register(foo, ["x", "y"])

	# NOTE: register() should be called only once, in _init, _ready
	# or _enter_tree

	# NOTE: objects must call debug.unregister() before being freed.


func _process(_delta: float) -> void:

	# example benchmark using a lambda

	# debug.print_bm(name, func, options)
	debug.print_bm("debug bm", func() -> void:
		monitoring_data()
		drawing_in_3d()
		drawing_in_2d()
		draw_help_info()
	, {smoothing=200, precision=2} ) # <-- NOTE: these arguments are all optional



func monitoring_data() -> void:

	# Example printing

	# debug.print(key value, float_precision=2)
	debug.print("fps", Engine.get_frames_per_second())
	debug.print("boolean thing", true)
	#debug.print("very long string that never ends", "very long string that never ends")
	debug.print("string thing", "dssdasdasda")
	debug.print("float", PI)
	debug.print("more precise", TAU, 7)
	debug.print("just this key", "")
	debug.print("", "just this value")
	debug.print("", "")
	#debug.print(10, "")
	debug.print("array", [0,1,2,3,4,5,6,7,8,9])
	debug.print("dic", {"foo1"="bar", "foo2"="bar"})
	debug.print("vector3", Vector3(0.15416156, 10, 0.2))
	debug.print("object", foo)
	debug.print("null value", null)

	# 'print_prop()' will attach the key/value to the node's property group
	# along with the ones already registered in _ready().
	debug.print_prop(foo, "z", foo.z)

	# grouped prints don't need to be together like they are here
	debug.print_grouped("Some Group", "days", 7)
	debug.print_grouped("Some Group", "weekend", "too short")
	debug.print_grouped("Some Group", "is_raining", false)



func drawing_in_2d() -> void:

	# Example 2D drawing

	# func draw_text(position, text, font_size, color, alignment=0)
	debug2d.draw_text(Vector2(350, 250), "Text without outline", 30, Color.ORANGE, true)
	# draw_text_outlined(position, text, font_size, out_size, color)
	debug2d.draw_text_outline(Vector2(750, 250), "Outline without text", 30, 3, Color.BLACK)

	# you can also
	debug2d.draw_text(Vector2(320, 200), "Lines", 25, Color.WHITE, true, 10)
	# debug2d.draw_line( p1, p2, color, thickness=1.0, antialiased=false )
	debug2d.draw_line(Vector2(300, 50), Vector2(400, 150), Color.DARK_GREEN, 4)

	# debug2d.draw_polyline( [points], color, thickness:=1.0, antialiased=false )
	debug2d.draw_polyline([
		Vector2(320,  70), Vector2(380,  70),
		Vector2(380, 130), Vector2(320, 130),
		Vector2(320,  90), Vector2(360,  90),
		Vector2(360, 110), Vector2(340, 110)
	], Color.BLUE_VIOLET, 4)


	debug2d.draw_text(Vector2(460, 200), "Circles", 25, Color.WHITE, true, 10)
	# debug2d.draw_circle( filled?, center, axis/radius, color, thickness=1.0, antialiased=false )
	debug2d.draw_circle(Vector2(500, 100), 50, Color.BLUE, false, 4)
	debug2d.draw_circle(Vector2(500, 100), 20, Color.RED, true)


	debug2d.draw_text(Vector2(600, 200), "Rects", 25, Color.WHITE, true, 10)
	# debug2d.draw_rect( filled?, rect, color, thickness:=1.0, antialiased=false )
	debug2d.draw_rect(Rect2(580, 50, 100, 100), Color.GREEN_YELLOW, false, 4)
	debug2d.draw_rect(Rect2(605, 75, 50, 50), Color.GOLD, true)


	debug2d.draw_text(Vector2(725, 200), "Arcs", 25, Color.WHITE, true, 10)
	# debug2d.draw_arc(center, radius, start_angle, end_angle, point_count, color, thickness=1.0, antialiased=false)
	var t := Time.get_ticks_msec()*0.001
	debug2d.draw_arc(Vector2(750, 100), 50, 0,  TAU*cos(t), 32, Color.ORANGE_RED, 4)
	debug2d.draw_arc(Vector2(750, 100), 30, 0, -TAU*cos(t), 32, Color.ORANGE_RED, 4)


	debug2d.draw_text(Vector2(850, 200), "Vectors", 25, Color.WHITE, true, 10)
	# debug2d.draw_vector( position, direction, color, thickness=1.0, antialiased=false )
	debug2d.draw_vector(Vector2(900, 100), (Vector2.RIGHT*75).rotated(PI* cos(t)), Color.DARK_SLATE_BLUE, 3)
	debug2d.draw_vector(Vector2(900, 100), (Vector2.LEFT*50).rotated(PI*sin(t)), Color.DARK_ORCHID, 3)


	debug2d.draw_text(Vector2(1000, 200), "Transforms", 25, Color.WHITE, true, 10)
	$Icon.rotate(-PI*cos(t)*0.01)
	$Icon.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	$Icon/Icon2.rotate(-PI*cos(t)*0.01)
	$Icon/Icon2.translate(Vector2(cos(t)*0.5, sin(t)*0.5))
	debug2d.draw_transform($Icon, 75, false, 4)
	debug2d.draw_transform($Icon/Icon2, 75, true, 4)
	debug2d.draw_transform($Icon/Icon2, 40, false, 4)

	pass


func drawing_in_3d() -> void:

	# Example 3D drawing

	var t := Time.get_ticks_msec()*0.001

	# debug3d.draw_text( position, text, color, size=1 )
	debug3d.draw_text(Vector3(0, 2.2, 0), "Lines", 1, Color.GREEN_YELLOW)
	# debug.draw_line( p1, p2, color, thickness=1.0 )
	debug3d.draw_line(Vector3(0, 2, -2), Vector3(0, 2, 2), Color.DARK_RED, 1)


	debug3d.draw_text(Vector3(-1, 1.2, 2.5), "Polylines", 1, Color.GREEN_YELLOW)
	# debug3d.draw_polyline( [points], color, thickness=1.0 )
	debug3d.draw_polyline( [
		Vector3(-1, 1, 3), Vector3(-1, 0, 3), Vector3(-1, 0, 2),
		Vector3(-1, 1, 2), Vector3( 0, 1, 2), Vector3( 0, 1, 3),
		Vector3( 0, 0, 3), Vector3( 0, 0, 2),
	], Color.DARK_ORANGE, 2 )


	debug3d.draw_text(Vector3(0, 1.2, 0), "Circles", 1, Color.GREEN_YELLOW)
	# debug3d.draw_circle( filled?, position, axis/radius, color, thickness=1.0 )

	debug3d.draw_circle(Vector3(), Vector3(0, cos(t), sin(t)).normalized()*1.0, Color.RED,   false, 2)
	debug3d.draw_circle(Vector3(), Vector3(cos(t), 0, sin(t)).normalized()*0.75, Color.GREEN, false, 2)
	debug3d.draw_circle(Vector3(), Vector3(cos(t), sin(t), 0).normalized()*0.5, Color.BLUE,  false, 2)

	debug3d.draw_text(Vector3(0, 0.2, -0.5), "Spheres", 1, Color.GREEN_YELLOW)
	# debug3d.draw_sphere( filled?, position, radius, color )
	debug3d.draw_sphere(Vector3(0, 0, 0), 0.3, Color.BLUE, true)
	debug3d.draw_sphere(Vector3(0, -0.5, -0.5), 0.5, Color.BLACK, false, 0.5)


	debug3d.draw_text(Vector3(0, 0.3, -2.5), "Cubes", 1, Color.GREEN_YELLOW)
	# debug3d.draw_cube( filled?, position, size, color )
	debug3d.draw_point_cube(Vector3(0, 0, -2), 0.25, Color.DARK_RED, true)


	debug3d.draw_text(Vector3(0.75, 0.75, 2), "Vectors", 1, Color.GREEN_YELLOW)
	# debug3d.draw_vector( position, direction, color, thickness=1.0 )
	debug3d.draw_vector(Vector3(1, 0, 1.5), Vector3(0, 2*sin(t), 2*sin(t)), Color.GREEN, 3)
	debug3d.draw_vector(Vector3(0.5, 0, 1.5), Vector3.UP*cos(t), Color.DARK_RED, 3)


	debug3d.draw_text(Vector3(0, -0.2, 0.75), "Origins", 1, Color.GREEN_YELLOW)
	# debug3d.draw_origin( position, size, thickness=1.0 )
	debug3d.draw_origin(Vector3(), 1, 4)

	debug3d.draw_text(Vector3(0, 1.3, -1.75), "AABBs", 1, Color.GREEN_YELLOW)
	var pos := Vector3(0.1*cos(t), 0, -2+(0.1*sin(t)))
	var size := Vector3.ONE
	# debug3d.draw_aabb( position, size, color, thickness=1.0 )
	debug3d.draw_aabb(AABB(pos, size), Color.DARK_SALMON, 1)


	debug3d.draw_text(Vector3(0, 1.3, -4.5), "Transforms", 1, Color.GREEN_YELLOW)
	# debug3d.draw_transform( node_3d, local:=false, size:=1.0, thickness=1.0 )
	$CSGTorus3D.rotate_z(deg_to_rad(1))
	$CSGTorus3D.rotate_y(deg_to_rad(1))
	debug3d.draw_transform($CSGTorus3D, true, 0.5, 4)



func draw_help_info() -> void:
	var ws := DisplayServer.window_get_size()
	var font_size := 20

	var text1 := "Default keys: '\\' or '~' to toggle info   |   'ctrl' + '\\' or '~' to toggle drawing"
	var width1 := debug2d.get_text_size(text1, font_size).x
	debug2d.draw_text(Vector2(ws.x/2.0-width1/2.0, ws.y-50), text1, font_size, Color.WHITE, true, 10)

	var text2 := "Right-Mouse + WASD to fly around   |   Shift to speed up"
	var width2 := debug2d.get_text_size(text2, font_size).x
	debug2d.draw_text(Vector2(ws.x/2.0-width2/2.0, ws.y-15), text2, font_size, Color.WHITE, true, 10)
