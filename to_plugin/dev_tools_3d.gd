#class_name DevTools3D
extends Node3D


var _draw_arrays:Dictionary

@onready var _dt :Node3D = preload("res://to_plugin/draw_tool_3d.gd").new()

@onready var _api_lookup := {
	lines     = _dt.bulk_lines,
	polylines = _dt.bulk_polylines,
	cones     = _dt.bulk_cones,
	circles   = _dt.bulk_circles,
	spheres   = _dt.bulk_spheres,
	cubes     = _dt.bulk_point_cube_faces,
	aabbs     = _dt.bulk_aabbs,
	labels    = _dt.bulk_text,
}



func _ready() -> void:
	#name = "DebugDrawing3D"
	add_child(_dt)

	for key:String in _api_lookup:
		_draw_arrays[key] = []


func _redraw() -> void:
	_dt.clear()

	for key:String in _draw_arrays:
		_api_lookup[key].call(_draw_arrays[key])


func _clean_up() -> void:
	for key:String in _draw_arrays:
		_draw_arrays[key].clear()


func _process_drawing() -> void:
	_redraw()
	_clean_up()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func draw_line(start:Vector3, end:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	_draw_arrays["lines"].append([start, end, color, thickness])
	#_dt.line(start, end, color, thickness)


func draw_polyline(points:Array, color:Color, thickness:=1.0, duration:=0.0) -> void:
	_draw_arrays["polylines"].append([points, color, thickness])
	#_dt.polyline(points, color, thickness)


func draw_cube(filled:bool, position:Variant, size:float, color:Color, duration:=0) -> void:
	if filled:
		_draw_arrays["cubes"].append([position, size, color])
	else:
		_draw_arrays["wire_cubes"].append([position, size, color])


func draw_aabb(p1:Variant, size:Variant, color:Color, thickness:=1.0, duration:=0) -> void:
	_draw_arrays["aabbs"].append([p1, size, color, thickness, false])


func draw_cone(filled:bool, position:Vector3, direction:Vector3, color:Color, length:=3.0, thickness:=1.0, duration:=0.0) -> void:
	if filled:
		_draw_arrays["cones"].append([position, direction, color, length, thickness])
	else:
		pass # _draw_arrays["wire_cones"].append([position, direction, color, length, thickness])


func draw_sphere(filled:bool, position:Vector3, size:float, color:Color, duration:=0.0) -> void:
	if filled:
		_draw_arrays["spheres"].append([position, color, size])
	else:
		pass # _draw_arrays["wire_spheres"].append([position, color, size])


func draw_circle(filled:bool, position:Vector3, radius:float, size:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	if filled:
		pass # _draw_arrays["filled_circles"].append([position, radius, size, color])
	else:
		_draw_arrays["circles"].append([position, radius, size, color, thickness])


func draw_text(position:Vector3, text:String, color:Color, size:=1.0, fixed_size:=false, duration:=0.0) -> void:
	_draw_arrays["labels"].append([position, text, color, size, fixed_size])


func draw_vector(position:Vector3, direction:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	_draw_arrays["lines"].append([position, position+direction, color, thickness])
	draw_cone(true, position+direction, direction, color, thickness*3, thickness)


func draw_transform(node:Node3D, size:float, local:=false, thickness:=1, duration:=0.0) -> void:
	var b := node.global_basis if not local else node.basis
	var o := node.global_position
	#var basis = tr.basis.orthonormalized()
#
	#draw_vector(o, b.x*size, Color.RED, thickness)
	#draw_vector(o, b.y*size, Color.GREEN, thickness)
	#draw_vector(o, b.z*size, Color(0, 0.133333, 1), thickness)

	draw_line(o, o+b.x*size, Color.RED, thickness)
	draw_line(o, o+b.y*size, Color.GREEN, thickness)
	draw_line(o, o+b.z*size, Color(0, 0.133333, 1), thickness)


func draw_origin(position:Vector3, size:=1.0, thickness:=1.0, duration:=0.0) -> void:
	draw_line(position, Vector3.RIGHT*size, Color.RED, thickness)
	draw_line(position, Vector3.UP*size, Color.GREEN, thickness)
	draw_line(position, Vector3.BACK*size, Color(0, 0.133333, 1), thickness)
