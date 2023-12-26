extends CanvasLayer

## An API for easily drawing 2D shapes.


var _data: Resource = load("res://addons/debug_tools/shared.gd")

var _drawing_visible := false

@onready var _dt:Node = load(_data.DT_2D_PATH).new()



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region LOOP
func _ready() -> void:
	layer = 125
	_init_config()
	#print(_ready)
	add_child(_dt)
	set_enabled(_drawing_visible, true)


func _process(_delta: float) -> void:
	assert(_drawing_visible == true)
	_dt.queue_redraw()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return

	if InputMap.has_action(_data.INPUT_ACTION_2D_DRAWING):
		if event.is_action_pressed(_data.INPUT_ACTION_2D_DRAWING):
			toggle()


func _init_config() -> void:
	var config: Resource = _data.get_config()
	if not config: return

	layer = config.drawing_tool_layer




#endregion LOOP



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Public API
## Toggles 2D drawing on/off.
func toggle()  -> void: set_enabled(not _drawing_visible)

## Enables 2D drawing.
func enable()  -> void: set_enabled(true)

## Disables 2D drawing.
func disable() -> void: set_enabled(false)

## Sets 2D drawing on or off. [br]
## [br]
## [b]Note:[/b] The parameter [param __force] is intended for internal usage,
## and should be ignored.
func set_enabled(vis:bool, __force:=false) -> void:
	if vis == _drawing_visible and not __force: return
	_drawing_visible = vis
	_dt.visible = _drawing_visible
	set_process(_drawing_visible)

## Draws a line from [param start] to [param end], using the given [param color]
## and line [param width]. It can optionally be antialiased.
func draw_line(start: Vector2, end: Vector2, color: Color, width:= 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	_dt.add_line([start, end, color, width, antialiased])


## Draws multiple line segments connected by the given [param points], using
## the given [param color] and line [param thickness]. [br]
## [br]
## [param color] can be a single [Color], or an [Array] of [Color]s with the
## same number of elements as [param points]. [br]
## [br]
## [b]Note:[/b] [param points] must be Vector2.
func draw_polyline(points: Array, color: Variant, thickness: float = 1.0, antialiased:=false ) -> void:
	if not _drawing_visible: return
	if color is Color:
		_dt.add_polyline([points, color, thickness, antialiased])
	elif color is Array:
		_dt.add_polyline_colors([points, color, thickness, antialiased])


## Draws multiple disconnected lines with a uniform [param thickness] and
## [param color]. Each line is defined by two consecutive points in the
## [param points] array, i.e. i-th segment consists of points[2 * i],
## points[2 * i + 1] endpoints. When drawing large amounts of lines, this
## is faster than using individual draw_line() calls. [br]
## [br]
## To draw interconnected lines, use [member draw_polyline()] instead.
func draw_multiline(points: Array, color: Color, thickness: float = 1.0) -> void:
	if not _drawing_visible: return
	_dt.add_multiline([points, color, thickness])


## Draws a circle at [param position], using the given [param radius],
## [param color] and line [param thickness]. It can optionally be [param filled]
## and [param antialiased].
func draw_circle(position:Vector2, radius:float, color:Color, filled:=false, thickness:=-1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	if filled: _dt.add_filled_circle([position, radius, color])
	else:      _dt.add_circle([position, radius, color, thickness, antialiased])


## Draws the rectangle [param rect] using the given [param color] and line
## [param thickness]. It can optionally be [param filled].
func draw_rect(rect:Rect2, color:Color, filled:=false, thickness:=-1.0) -> void:
	if not _drawing_visible: return
	_dt.add_rect([rect, color, filled, thickness])


# draw_arc(center, radius, start_angle, end_angle, point_count, color, thickness)
func draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, thickness: float = 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	_dt.add_arc([center, radius, start_angle, end_angle, point_count, color, thickness, antialiased])


func draw_vector(position: Vector2, direction: Vector2, color: Color, thickness: float = 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	var a := position
	var b := position+direction

	draw_line(position, position+direction, color, thickness, antialiased)

	var inv_dir := (b-a).normalized()*20
	var c := b + inv_dir.rotated(deg_to_rad(150))
	var d := b + inv_dir.rotated(deg_to_rad(210))
	#var points = PoolVector2Array([a, b, c])
	#draw_polygon(points, PoolColorArray([color]))
	draw_line(b, c, color, thickness, antialiased)
	draw_line(b, d, color, thickness, antialiased)


func draw_transform(node:Node2D, size:float, local:=false, thickness:=1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	var t :Transform2D = node.global_transform if not local else node.transform
	var o :Vector2 = node.global_transform.origin

	draw_line(o, o+t.x.normalized()*size, Color.RED,             thickness, antialiased)
	draw_line(o, o+t.y.normalized()*size, Color.GREEN,             thickness, antialiased)
	#draw_vector(o, t.x*size, Color.RED,             thickness, antialiased)
	#draw_vector(o, t.y*size, Color.GREEN,           thickness, antialiased)
#

	#draw_vector(b, c, color, thickness, antialiased)

#draw_string(font, Vector2(500, 300), str, 0, ss, font_size, Color.RED)
func draw_text(position:Vector2, text:String, font_size:float,
			   color:Color, outline:=false, outline_size:=1.0,
			   outline_color:=Color.BLACK
) -> void:
	if not _drawing_visible: return
	_dt.add_string([position, text, 0, font_size, color])
	if outline:
		draw_text_outline(position, text, font_size, outline_size, outline_color)


func draw_text_outline(position:Vector2, text:String, font_size:float,
					   outline_size:float, color:Color
) -> void:
	if not _drawing_visible: return
	_dt.add_string_outline([position, text,  0,  font_size, outline_size, color])

func get_text_size(text:String, font_size:int) -> Vector2:
	return _dt.get_text_size(text, font_size)


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


