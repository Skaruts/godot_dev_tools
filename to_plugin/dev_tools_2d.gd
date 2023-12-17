#class_name DevTools2D
extends Node

@onready var _dt :Node = preload("res://to_plugin/draw_tool_2d.gd").new()

var visible : bool :
	get: return _dt.visible
	set(v): _dt.visible = v


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region LOOP
func _ready() -> void:
	#name = "DebugDrawing2D"
	add_child(_dt)


func _process_drawing() -> void:
	_dt.queue_redraw()


#endregion LOOP




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Public API

func draw_line(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased: bool = false) -> void:
	_dt.add_line([from, to, color, width, antialiased])

func draw_polyline(points: Array, color: Color, width: float = 1.0, antialiased: bool = false ) -> void:
	_dt.add_polyline([points, color, width, antialiased])

func draw_multiline(points: Array, color: Color, width: float = 1.0) -> void:
	_dt.add_multiline([points, color, width])

func draw_polyline_colors(points:Array, colors:Array, width: float = 1.0, antialiased: bool = false) -> void:
	_dt.add_polyline_colors([points, colors, width, antialiased])

# func primitive(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array, texture: Texture = null, width: float = 1.0, normal_map: Texture = null )
# 	primitives.append([points, colors, uvs, texture, width, normal_map])

# func rect(rect: Rect2, color: Color, filled: bool = true, width: float = 1.0, antialiased: bool = false ) -> void:
# 	rects.append([rect, color, filled, width, antialiased])

 #func circle(position: Vector2, radius: float, color: Color) -> void:
 	#circles.append([position, radius, color])

# func polygon(points: Array, colors: PoolColorArray, antialiased: bool = false ) -> void:
# 	polygons.append([points, colors, antialiased])

# func colored_polygon(points: Array, color: Color, antialiased: bool = false) -> void:
# 	col_polygons.append([points, color, antialiased])

func draw_circle(filled:bool, position:Vector2, radius:float, color:Color, width:=-1.0, antialiased:=false) -> void:
	if filled: _dt.add_filled_circle([position, radius, color])
	else:      _dt.add_circle([position, radius, color, width, antialiased])










# draw_arc(center: Vector2, radius: float, start_angle: float, end_angle: float, point_count: int, color: Color, width: float = 1.0, antialiased: bool = false)
# draw_char(font: Font, position: Vector2, char: String, next: String, modulate: Color = Color( 1, 1, 1, 1 ))
# draw_circle(position: Vector2, radius: float, color: Color)
# draw_colored_polygon(points: PoolVector2Array, color: Color, uvs: PoolVector2Array = PoolVector2Array(), texture: Texture = null, normal_map: Texture = null, antialiased: bool = false)
# draw_line(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased: bool = false)
# draw_mesh(mesh: Mesh, texture: Texture, normal_map: Texture = null, transform: Transform2D = Transform2D( 1, 0, 0, 1, 0, 0 ), modulate: Color = Color( 1, 1, 1, 1 ) )
# draw_multiline(points: PoolVector2Array, color: Color, width: float = 1.0, antialiased: bool = false )
# draw_multiline_colors(points: PoolVector2Array, colors: PoolColorArray, width: float = 1.0, antialiased: bool = false )
# draw_multimesh(multimesh: MultiMesh, texture: Texture, normal_map: Texture = null )
# draw_polygon(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array = PoolVector2Array(), texture: Texture = null, normal_map: Texture = null, antialiased: bool = false )
# draw_polyline(points: PoolVector2Array, color: Color, width: float = 1.0, antialiased: bool = false )

# draw_primitive(points: PoolVector2Array, colors: PoolColorArray, uvs: PoolVector2Array, texture: Texture = null, width: float = 1.0, normal_map: Texture = null )
# draw_rect(rect: Rect2, color: Color, filled: bool = true, width: float = 1.0, antialiased: bool = false )
# draw_set_transform(position: Vector2, rotation: float, scale: Vector2 )
# draw_set_transform_matrix(xform: Transform2D )
# draw_string(font: Font, position: Vector2, text: String, modulate: Color = Color( 1, 1, 1, 1 ), clip_w: int = -1 )
# draw_style_box(style_box: StyleBox, rect: Rect2 )
# draw_texture(texture: Texture, position: Vector2, modulate: Color = Color( 1, 1, 1, 1 ), normal_map: Texture = null )
# draw_texture_rect(texture: Texture, rect: Rect2, tile: bool, modulate: Color = Color( 1, 1, 1, 1 ), transpose: bool = false, normal_map: Texture = null )
# draw_texture_rect_region(texture: Texture, rect: Rect2, src_rect: Rect2, modulate: Color = Color( 1, 1, 1, 1

#endregion Public API


