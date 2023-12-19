extends CanvasLayer

var _data:Resource = preload("res://addons/sk_dev_tools/shared.gd")

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

	if InputMap.has_action("dev_tools_2d_drawing"):
		if event.is_action_pressed("dev_tools_2d_drawing"):
			toggle()
	#else:
		#var mods_ok: bool = event.ctrl_pressed  \
			   #and not event.shift_pressed \
			   #and not event.alt_pressed
#
		#if event.keycode in _data.DEF_KEYS and event.pressed \
		#and not event.echo and mods_ok:
			#toggle()


func _init_config() -> void:
	var config: Resource = _data.get_config()
	if not config: return

	layer = config.drawing_tool_layer




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
func draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	_dt.add_arc([center, radius, start_angle, end_angle, point_count, color, width, antialiased])


func draw_vector(position: Vector2, direction: Vector2, color: Color, width: float = 1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	var a := position
	var b := position+direction

	draw_line(position, position+direction, color, width, antialiased)

	var inv_dir := (b-a).normalized()*20
	var c := b + inv_dir.rotated(deg_to_rad(150))
	var d := b + inv_dir.rotated(deg_to_rad(210))
	#var points = PoolVector2Array([a, b, c])
	#draw_polygon(points, PoolColorArray([color]))
	draw_line(b, c, color, width, antialiased)
	draw_line(b, d, color, width, antialiased)


func draw_transform(node:Node2D, size:float, local:=false, width:=1.0, antialiased:=false) -> void:
	if not _drawing_visible: return
	var t :Transform2D = node.global_transform if not local else node.transform
	var o :Vector2 = node.global_transform.origin

	draw_line(o, o+t.x.normalized()*size, Color.RED,             width, antialiased)
	draw_line(o, o+t.y.normalized()*size, Color.GREEN,             width, antialiased)
	#draw_vector(o, t.x*size, Color.RED,             width, antialiased)
	#draw_vector(o, t.y*size, Color.GREEN,           width, antialiased)


	#draw_vector(b, c, color, width, antialiased)

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


