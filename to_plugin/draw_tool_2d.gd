extends Node2D

var _draw_arrays:Dictionary

@onready var _api_lookup := {
	lines             = _render_lines,
	polylines         = _render_polylines,
	multilines        = _render_multilines,
	#colored_polylines = _render_polyline_colors,
	rects             = _render_rects,
	#filled_rects      = _render_filled_rects,
	circles           = _render_circles,
	filled_circles    = _render_filled_circles,
	arcs              = _render_arcs,
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



func add_multiline(multiline:Array) -> void:
	_draw_arrays["multilines"].append(multiline)

func _render_multilines(multilines:Array) -> void:
	for mln:Array in multilines:
		draw_multiline(mln[0], mln[1], mln[2])



func add_polyline_colors(polyline_colors:Array) -> void:
	_draw_arrays["polylines_colors"].append(polyline_colors)

func _render_polyline_colors(polyline_colors:Array) -> void:
	for plnc:Array in polyline_colors:
		draw_polyline_colors(plnc[0], plnc[1], plnc[2], plnc[3])



func add_circle(circle:Array) -> void:
	_draw_arrays["circles"].append(circle)

func _render_circles(circles:Array) -> void:
	for c:Array in circles:
		draw_arc(c[0], c[1], 0, 360, 32, c[2], c[3], c[4])



func add_filled_circle(filled_circle:Array) -> void:
	_draw_arrays["filled_circles"].append(filled_circle)

func _render_filled_circles(filled_circles:Array) -> void:
	for c:Array in filled_circles:
		draw_circle(c[0], c[1], c[2])



func add_rect(rect:Array) -> void:
	_draw_arrays["rects"].append(rect)

func _render_rects(rects:Array) -> void:
	for c:Array in rects:
		draw_rect(c[0], c[1], c[2], c[3])



func add_arc(arc:Array) -> void:
	_draw_arrays["arcs"].append(arc)

func _render_arcs(arcs:Array) -> void:
	for c:Array in arcs:
		draw_arc(c[0], c[1], c[2], c[3], c[4], c[5], c[6], c[7])




#endregion Private API
