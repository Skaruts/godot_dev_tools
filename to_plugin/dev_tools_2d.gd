extends Node


const _DEF_KEYS:Array[int] = [KEY_BACKSLASH, KEY_ASCIITILDE]

var _drawing_visible := false
var _input_checker_func:Callable

@onready var _dt :Node = preload("res://to_plugin/draw_tool_2d.gd").new()



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region LOOP
func _ready() -> void:
	#name = "DebugDrawing2D"
	add_child(_dt)
	_init_input_actions()


func _process(_delta: float) -> void:
	#if not _drawing_visible: return
	assert(_drawing_visible == true)
	_dt.queue_redraw()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	_input_checker_func.call(event)


func _init_input_actions() -> void:
	if InputMap.has_action("dev_tools_drawing"):
		_input_checker_func = \
				func(event:InputEventKey) -> void:
					if event.is_action_pressed("dev_tools_drawing"):
						toggle()
	else:
		_input_checker_func = \
				func(event:InputEventKey) -> void:
					var mods_ok := event.ctrl_pressed  \
						   and not event.shift_pressed \
						   and not event.alt_pressed

					if event.keycode in _DEF_KEYS and event.pressed \
					and not event.echo and mods_ok:
						toggle()

#endregion LOOP



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Public API
func toggle()  -> void: set_enabled(not _drawing_visible)
func enable()  -> void: set_enabled(true)
func disable() -> void: set_enabled(false)
func set_enabled(vis:bool, force:=false) -> void:
	if vis == _drawing_visible and not force: return
	_drawing_visible = vis
	_dt.visible = _drawing_visible
	set_process(_drawing_visible)



func draw_line(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	_dt.add_line([from, to, color, width, antialiased])


func draw_polyline(points: Array, color: Variant, width: float = 1.0, antialiased:=false ) -> void:
	if not _drawing_visible: return
	if color is Color:
		_dt.add_polyline([points, color, width, antialiased])
	elif color is Array:
		_dt.add_polyline_colors([points, color, width, antialiased])


func draw_multiline(points: Array, color: Color, width: float = 1.0) -> void:
	if not _drawing_visible: return
	_dt.add_multiline([points, color, width])


func draw_circle(filled:bool, position:Vector2, radius:float, color:Color, width:=-1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	if filled: _dt.add_filled_circle([position, radius, color])
	else:      _dt.add_circle([position, radius, color, width, antialiased])


func draw_rect(filled:bool, rect:Rect2, color:Color, width:=-1.0) -> void:
	if not _drawing_visible: return
	_dt.add_rect([rect, color, filled, width])

# draw_arc(center, radius, start_angle, end_angle, point_count, color, width)
func draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased:=false):
	if not _drawing_visible: return
	_dt.add_arc([center, radius, start_angle, end_angle, point_count, color, width, antialiased])





# func polygon(points: Array, colors: PoolColorArray, antialiased:=false ) -> void:
# 	polygons.append([points, colors, antialiased])

# func colored_polygon(points: Array, color: Color, antialiased:=false) -> void:
# 	col_polygons.append([points, color, antialiased])

# draw_style_box(style_box: StyleBox, rect: Rect2 )
# draw_texture(texture: Texture, position: Vector2, modulate: Color = Color( 1, 1, 1, 1 ), normal_map: Texture = null )
# draw_texture_rect(texture: Texture, rect: Rect2, tile: bool, modulate: Color = Color( 1, 1, 1, 1 ), transpose: bool = false, normal_map: Texture = null )
# draw_texture_rect_region(texture: Texture, rect: Rect2, src_rect: Rect2, modulate: Color = Color( 1, 1, 1, 1






# func primitive(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array, texture: Texture = null, width: float = 1.0, normal_map: Texture = null )
# 	primitives.append([points, colors, uvs, texture, width, normal_map])

# draw_char(font: Font, position: Vector2, char: String, next: String, modulate: Color = Color( 1, 1, 1, 1 ))
# draw_mesh(mesh: Mesh, texture: Texture, normal_map: Texture = null, transform: Transform2D = Transform2D( 1, 0, 0, 1, 0, 0 ), modulate: Color = Color( 1, 1, 1, 1 ) )
# draw_string(font: Font, position: Vector2, text: String, modulate: Color = Color( 1, 1, 1, 1 ), clip_w: int = -1 )


#endregion Public API


