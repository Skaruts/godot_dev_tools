extends Node3D


var data: Node = load("res://addons/sk_debug_tools/data.gd").new()

var _draw_arrays:Dictionary
var _drawing_visible := false

var _color_x_axis:Color
var _color_y_axis:Color
var _color_z_axis:Color

#@onready var _dt :Node3D = preload("res://to_plugin/draw_tool_3d.gd").new()
@onready var _dt:Node = load(data.DT_3D_PATH).new()
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


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region LOOP
func _ready() -> void:
	#print(_ready)
	add_child(_dt)

	_init_config()

	for key:String in _api_lookup:
		_draw_arrays[key] = []

	set_enabled(_drawing_visible, true)


func _init_config() -> void:
	var data: Node = load("res://addons/sk_debug_tools/data.gd").new()

	if not FileAccess.file_exists(data.DT_SETTINGS_PATH):
		return

	var config := load(data.DT_SETTINGS_PATH)

	_color_x_axis = config.x_axis_color
	_color_y_axis = config.y_axis_color
	_color_z_axis = config.z_axis_color


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	if InputMap.has_action("dev_tools_drawing"):
		if event.is_action_pressed("dev_tools_drawing"):
			toggle()
	else:
		var mods_ok :bool = event.ctrl_pressed  \
			   and not event.shift_pressed \
			   and not event.alt_pressed

		if event.keycode in data.DEF_KEYS and event.pressed \
		and not event.echo and mods_ok:
			toggle()


func _process(_delta: float) -> void:
	assert(_drawing_visible == true)
	_redraw()
	_clean_up()


func _redraw() -> void:
	_dt.clear()

	for key:String in _draw_arrays:
		_api_lookup[key].call(_draw_arrays[key])


func _clean_up() -> void:
	for key:String in _draw_arrays:
		_draw_arrays[key].clear()



#endregion LOOP




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func toggle()  -> void: set_enabled(not _drawing_visible)
func enable()  -> void: set_enabled(true)
func disable() -> void: set_enabled(false)
func set_enabled(vis:bool, force:=false) -> void:
	if vis == _drawing_visible and not force: return
	_drawing_visible = vis
	visible = _drawing_visible
	set_process(_drawing_visible)



func draw_line(start:Vector3, end:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["lines"].append([start, end, color, thickness])


func draw_polyline(points:Array, color:Color, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["polylines"].append([points, color, thickness])


func draw_cube(filled:bool, position:Variant, size:float, color:Color, duration:=0) -> void:
	if not _drawing_visible: return
	if filled:
		_draw_arrays["cubes"].append([position, size, color])
	else:
		_draw_arrays["wire_cubes"].append([position, size, color])


func draw_aabb(aabb:AABB, color:Color, thickness:=1.0, duration:=0) -> void:
	if not _drawing_visible: return
	_draw_arrays["aabbs"].append([aabb, color, thickness, false])


func draw_cone(filled:bool, position:Vector3, direction:Vector3, color:Color, length:=3.0, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	if filled:
		_draw_arrays["cones"].append([position, direction, color, length, thickness])
	else:
		pass # _draw_arrays["wire_cones"].append([position, direction, color, length, thickness])


func draw_sphere(filled:bool, position:Vector3, size:float, color:Color, duration:=0.0) -> void:
	if not _drawing_visible: return
	if filled:
		_draw_arrays["spheres"].append([position, color, size])
	else:
		pass # _draw_arrays["wire_spheres"].append([position, color, size])


func draw_circle(filled:bool, position:Vector3, radius:float, size:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	if filled:
		pass # _draw_arrays["filled_circles"].append([position, radius, size, color])
	else:
		_draw_arrays["circles"].append([position, radius, size, color, thickness])


func draw_text(position:Vector3, text:String, color:Color, size:=1.0, fixed_size:=false, duration:=0.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["labels"].append([position, text, color, size, fixed_size])


func draw_vector(position:Vector3, direction:Vector3, color:Color, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["lines"].append([position, position+direction, color, thickness])
	draw_cone(true, position+direction, direction, color, thickness*3, thickness)


func draw_transform(node:Node3D, size:float, local:=false, thickness:=1, duration:=0.0) -> void:
	if not _drawing_visible: return
	var b := node.global_basis if not local else node.basis
	var o := node.global_position
	#var basis = tr.basis.orthonormalized()





	draw_line(o, o+b.x*size, _color_x_axis, thickness)
	draw_line(o, o+b.y*size, _color_y_axis, thickness)
	draw_line(o, o+b.z*size, _color_z_axis, thickness)


func draw_origin(position:Vector3, size:=1.0, thickness:=1.0, duration:=0.0) -> void:
	if not _drawing_visible: return
	draw_line(position, Vector3.RIGHT*size, _color_x_axis, thickness)
	draw_line(position, Vector3.UP*size, _color_y_axis, thickness)
	draw_line(position, Vector3.BACK*size, _color_z_axis, thickness)
