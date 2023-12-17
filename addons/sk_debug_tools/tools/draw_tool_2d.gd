extends Node2D


var _font := ThemeDB.fallback_font
var _draw_arrays:Dictionary

@onready var _api_lookup := {
	lines             = _render_lines,
	polylines         = _render_polylines,
	polyline_colors   = _render_polyline_colors,
	multilines        = _render_multilines,
	rects             = _render_rects,
	circles           = _render_circles,
	filled_circles    = _render_filled_circles,
	arcs              = _render_arcs,
	strings           = _render_strings,
	string_outlines   = _render_string_outlines,
	#polygons          = bulk_polygons,
	#col_polygons      = bulk_col_polygons,
	#primitives        = bulk_primitives,
}



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region LOOP
func _ready() -> void:
	name = "DrawNode"
	_initdraw_arrays()


func _draw() -> void:
	for key:String in _draw_arrays:
		_api_lookup[key].call(_draw_arrays[key])
	_clean_up()


func _clean_up() -> void:
	for key:String in _draw_arrays:
		_draw_arrays[key].clear()


func _initdraw_arrays() -> void:
	for key:String in _api_lookup:
		_draw_arrays[key] = []



#endregion LOOP




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		Private API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Private API

func add_line(line:Array) -> void:
	_draw_arrays["lines"].append(line)

func _render_lines(lines:Array) -> void:
	for ln:Array in lines:
		draw_line(ln[0], ln[1], ln[2], ln[3], ln[4])



func add_polyline(polyline:Array) -> void:
	_draw_arrays["polylines"].append(polyline)

func _render_polylines(polylines:Array) -> void:
	for pln:Array in polylines:
		draw_polyline(pln[0], pln[1], pln[2], pln[3])



func add_polyline_colors(polyline_colors:Array) -> void:
	_draw_arrays["polyline_colors"].append(polyline_colors)

func _render_polyline_colors(polyline_colors:Array) -> void:
	for plnc:Array in polyline_colors:
		draw_polyline_colors(plnc[0], plnc[1], plnc[2], plnc[3])



func add_multiline(multiline:Array) -> void:
	_draw_arrays["multilines"].append(multiline)

func _render_multilines(multilines:Array) -> void:
	for mln:Array in multilines:
		draw_multiline(mln[0], mln[1], mln[2])



func add_circle(circle:Array) -> void:
	_draw_arrays["circles"].append(circle)

func _render_circles(circles:Array) -> void:
	for c:Array in circles:
		draw_arc(c[0], c[1], 0, TAU, 32, c[2], c[3], c[4])



func add_filled_circle(filled_circle:Array) -> void:
	_draw_arrays["filled_circles"].append(filled_circle)

func _render_filled_circles(filled_circles:Array) -> void:
	for fc:Array in filled_circles:
		draw_circle(fc[0], fc[1], fc[2])



func add_rect(rect:Array) -> void:
	_draw_arrays["rects"].append(rect)

func _render_rects(rects:Array) -> void:
	for r:Array in rects:
		draw_rect(r[0], r[1], r[2], r[3])



func add_arc(arc:Array) -> void:
	_draw_arrays["arcs"].append(arc)

func _render_arcs(arcs:Array) -> void:
	for a:Array in arcs:
		draw_arc(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7])



func add_string(string:Array) -> void:
	_draw_arrays["strings"].append(string)

func _render_strings(strings:Array) -> void:
	for a:Array in strings:
		var str:String = a[1]
		var font_size:float = a[3]
		var width := _font.get_string_size(str, 0, -1, font_size).x
					#( pos, text, align, font_size, color)
		#draw_string(font, pos,  str, align, width, font_size, color)
		draw_string(_font, a[0], str, a[2], width, font_size, a[4])


func add_string_outline(string_outline:Array) -> void:
	_draw_arrays["string_outlines"].append(string_outline)

func _render_string_outlines(string_outlines:Array) -> void:
	for a:Array in string_outlines:
		var str:String = a[1]
		var font_size:float = a[3]
		var width := _font.get_string_size(str, 0, -1, font_size).x
						#p, t, alin, fs, os, c
		#draw_string_outline(f, p, t, alin, w, fs, os, c)
		draw_string_outline(_font, a[0], str, a[2], width, font_size, a[4], a[5])






#endregion Private API
