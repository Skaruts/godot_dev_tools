class_name CanvasDrawTool3D_FOO extends Node2D

var _draw_arrays:Dictionary

@onready var _api_lookup := {
	lines             = _render_lines,
	polylines         = _render_polylines,
	multilines        = _render_multilines,
	#colored_polylines = _render_polyline_colors,
	#rects             = bulk_rects,
	circles           = _render_circles,
	filled_circles    = _render_filled_circles,
	#polygons          = bulk_polygons,
	#col_polygons      = bulk_col_polygons,
	#primitives        = bulk_primitives,
}

func _ready() -> void:
	name = "DebugDrawing2D"
	for key:String in _api_lookup:
		_draw_arrays[key] = []


func _draw() -> void:
	for key:String in _draw_arrays:
		_api_lookup[key].call(_draw_arrays[key])

	_clean_up()


func _process_drawing() -> void:

	queue_redraw()


func _clean_up() -> void:
	for key:String in _draw_arrays:
		_draw_arrays[key].clear()

func line(from: Vector2, to: Vector2, color: Color, width: float = 1.0, antialiased: bool = false) -> void:
	_draw_arrays["lines"].append([from, to, color, width, antialiased])

func polyline(points: Array, color: Color, width: float = 1.0, antialiased: bool = false ) -> void:
	_draw_arrays["polylines"].append([points, color, width, antialiased])

func multiline(points: Array, color: Color, width: float = 1.0) -> void:
	_draw_arrays["multilines"].append([points, color, width])

func polyline_colors(points:Array, colors:Array, width: float = 1.0, antialiased: bool = false) -> void:
	_draw_arrays["colored_polylines"].append([points, colors, width, antialiased])

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

func circle(position:Vector2, radius:float, color:Color, width:=-1.0, antialiased:=false) -> void:
	_draw_arrays["circles"].append([position, radius, color, width, antialiased])

func _render_circles(circles:Array) -> void:
	for c:Array in circles:
		draw_arc(c[0], c[1], 0, 360, 32, c[2], c[3], c[4])



func filled_circle(position: Vector2, radius: float, color: Color) -> void:
	_draw_arrays["filled_circles"].append([position, radius, color])

func _render_filled_circles(filled_circles:Array) -> void:
	for c:Array in filled_circles:
		draw_circle(c[0], c[1], c[2])






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


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#		private
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
# add lines from array of lines [ [p1, p2], [p1, p2], ...])
func _render_lines(lines:Array) -> void:
	#print(_draw_arrays["lines"].size())
	for ln:Array in lines:
		draw_line(ln[0], ln[1], ln[2], ln[3], ln[4])

func _render_polylines(polylines:Array) -> void:
	for pln:Array in polylines:
		draw_polyline(pln[0], pln[1], pln[2], pln[3])

func _render_multilines(multilines:Array) -> void:
	for mln:Array in multilines:
		draw_multiline(mln[0], mln[1], mln[2])

func _render_polyline_colors(polyline_colors:Array) -> void:
	for plnc:Array in polyline_colors:
		draw_polyline_colors(plnc[0], plnc[1], plnc[2], plnc[3])
