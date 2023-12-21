extends Node3D

## An API for easily drawing 3D shapes.

var _data: Resource = load("res://addons/gd_dev_toolbox/shared.gd")

var _draw_arrays:Dictionary
var _drawing_visible := false

var _color_x_axis:Color = Color(0.72, 0.02, 0.02)
var _color_y_axis:Color = Color(0.025, 0.31, 0)
var _color_z_axis:Color = Color(0, 0.10, 1)

#@onready var _dt :Node3D = preload("res://to_plugin/draw_tool_3d.gd").new()
@onready var _dt:Node = load(_data.DT_3D_PATH).new()
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
	var config: Resource = _data.get_config()
	if not config: return

	_color_x_axis = config.x_axis_color
	_color_y_axis = config.y_axis_color
	_color_z_axis = config.z_axis_color


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return

	if InputMap.has_action("dev_tools_3d_drawing"):
		if event.is_action_pressed("dev_tools_3d_drawing"):
			toggle()


func _process(_delta: float) -> void:
	assert(_drawing_visible == true)
	Toolbox.print_bm(str(_process), func() -> void:
		_redraw()
		_clean_up()
	, {precision=2})


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
## Toggles 3D drawing on/off.
func toggle()  -> void: set_enabled(not _drawing_visible)

## Enables 3D drawing.
func enable()  -> void: set_enabled(true)

## Disables 3D drawing.
func disable() -> void: set_enabled(false)

## Sets 3D drawing on or off. [br]
## [br]
## [b]Note:[/b] The parameter [param __force] is intended for internal usage,
## and should be ignored.
func set_enabled(vis:bool, __force:=false) -> void:
	if vis == _drawing_visible and not __force: return
	_drawing_visible = vis
	visible = _drawing_visible
	set_process(_drawing_visible)


## Draws a line from [param start] to [param end], using the given [param color]
## and line [param thickness].
func draw_line(start:Vector3, end:Vector3, color:Color, thickness:=1.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["lines"].append([start, end, color, thickness])
	#_dt.line(	start, end, color, thickness)


## Draws multiple line segments connected by the given [param points], using
## the given [param color] and line [param thickness]. [br]
## [br]
## [param color] can be a single [Color], or an [Array] of [Color]s with the
## same number of elements as [param points]. [br]
## [br]
## [b]Note:[/b] [param points] must be Vector3.
func draw_polyline(points:Array, color:Variant, thickness:=1.0) -> void:
	if not _drawing_visible: return
	if color is Array: assert(color.size() == points.size())
	_draw_arrays["polylines"].append([points, color, thickness])


## [param TODO: this must be changed. Points vs cubes/spheres]
## Draws a point using a cube shape at [param position] with size [param size],
## using the given [param color].
@warning_ignore("shadowed_variable_base_class")
func draw_point_cube(position:Variant, size:float, color:Color, filled:=false) -> void:
	if not _drawing_visible: return
	if filled:
		_draw_arrays["cubes"].append([position, size, color])
	else:
		_draw_arrays["wire_cubes"].append([position, size, color])


## Draws an [AABB], using the given [param color] and line [param thickness]. [br]
## [br]
## [AABB] is naturally a cube wireframe and cannot be filled.
func draw_aabb(aabb:AABB, color:Color, thickness:=1.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["aabbs"].append([aabb, color, thickness, false])


## Draws a sphere at [param position], using the given [param size] and [param color]. [br]
## [br]
## If [param filled] is [code]false[/code], the sphere will be a wireframe.
@warning_ignore("shadowed_variable_base_class")
func draw_sphere(position:Vector3, size:float, color:Color, filled:=false) -> void:
	if not _drawing_visible: return
	#if filled:
	_draw_arrays["spheres"].append([position, color, size])
	#else:
	#	_draw_arrays["wire_spheres"].append([position, color, size])


## Draws a circle at [param position], using the given [param color] and line
## [param thickness]. The circle will be drawn perpendicular to [param normal],
## and the radius of the circle will be the length of the [param normal] vector. [br]
## [br]
## It can optionally be [param filled] or hollow.
## [br]
## [b]Note:[/b] the parameter [param filled] currently has no effect (NIY).
@warning_ignore("shadowed_variable_base_class")
func draw_circle(position:Vector3, normal:Vector3, color:Color, filled:=false, thickness:=1.0) -> void:
	if not _drawing_visible: return
	#if filled:
	#	_draw_arrays["filled_circles"].append([position, radius, normal, color])
	#else:
	_draw_arrays["circles"].append([position, normal, color, thickness])


## Draws [param text] at [param position], using the given [param size] and [param color]. [br]
## [br]
## If [param fixed_size] is [code]true[/code], the text will display always
## at the same size, regardless of the distance to the camera.
@warning_ignore("shadowed_variable_base_class")
func draw_text(position:Vector3, text:String, size:float, color:Color, fixed_size:=false) -> void:
	if not _drawing_visible: return
	_draw_arrays["labels"].append([position, text, color, size, fixed_size])


## [param TODO: this is here only for the vectors, and needs to be sorted out]
@warning_ignore("shadowed_variable_base_class")
func draw_cone(position:Vector3, direction:Vector3, color:Color, filled:=false, thickness:=1.0) -> void:
	if not _drawing_visible: return
	#if filled:
	_draw_arrays["cones"].append([position, direction, color, thickness])
	#else:
	#_draw_arrays["wire_cones"].append([position, direction, color, thickness])


## Draws an arrow representing a vector, at [param position], pointing toward
## the [param direction] vector, using the given [param color] and line
## [param thickness].[br]
## [br]
## The length of the arrow will be the length of the [param direction] vector.
@warning_ignore("shadowed_variable_base_class")
func draw_vector(position:Vector3, direction:Vector3, color:Color, thickness:=1.0) -> void:
	if not _drawing_visible: return
	_draw_arrays["lines"].append([position, position+direction, color, thickness])
	draw_cone(position+direction, direction, color, true, thickness*2)


## Draws the [param node]'s [transform] using the given [param size] for the
## length of the lines, and line [param thickness] [br]
## [br]
## [param local] determines whether to use the local or global transform.
func draw_transform(node:Node3D, local:=false, size:=1, thickness:=1) -> void:
	if not _drawing_visible: return
	var b := node.global_basis if not local else node.basis
	var o := node.global_position

	draw_line(o, o+b.x*size, _color_x_axis, thickness)
	draw_line(o, o+b.y*size, _color_y_axis, thickness)
	draw_line(o, o+b.z*size, _color_z_axis, thickness)


## Draws the [param position] vector as three RGB lines representing a 3D
## origin, using the given [param size] for the length of the lines, and
## line [param thickness].
@warning_ignore("shadowed_variable_base_class")
func draw_origin(position:Vector3, size:=1.0, thickness:=1.0) -> void:
	if not _drawing_visible: return
	draw_line(position, Vector3.RIGHT*size, _color_x_axis, thickness)
	draw_line(position, Vector3.UP*size, _color_y_axis, thickness)
	draw_line(position, Vector3.BACK*size, _color_z_axis, thickness)
