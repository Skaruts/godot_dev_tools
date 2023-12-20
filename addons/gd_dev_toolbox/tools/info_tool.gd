extends CanvasLayer


var _text_size       := 16
var _def_float_precision :int = 2
var _outline_size    := 10

var _draw_background := true
var _draw_border     := true
var _bg_color        := Color("1a1a1a99")
var _border_width    := 1
var _border_color    := Color("ffffff5d")

var _color_null    := Color.FUCHSIA
var _color_number  := Color(0.81, 0.64, 0.99)
var _color_string  := Color(1, 0.90, 0.66)
var _color_bool    := Color(1, 0.72, 0.26)
var _color_builtin := Color(0.74, 0.84, 1)
var _color_object  := Color(0.30, 0.86, 0.30)

var _color_key     := Color.LIGHT_GRAY
var _color_group   := Color(1, 0.37, 0.37)

enum {
	SEC,
	MSEC,
}

var _def_bm_smoothing:int = 15
var _bm_time_units:int = MSEC
var _bm_precision:int = 4
var _max_smoothing := 100
var _max_bm_precision := 16

const _GROUP_PREFIX := "    "
const _NODE_PROP_PREFIX := "    "
const _SPACER := ' ' # this prevents outlines getting cut off at the edges of the labels

var _colors_lookup := {
	TYPE_NIL                   : _color_null,		TYPE_BOOL                  : _color_bool,
	TYPE_INT                   : _color_number,		TYPE_FLOAT                 : _color_number,
	TYPE_STRING                : _color_string,		TYPE_VECTOR2               : _color_builtin,
	TYPE_VECTOR2I              : _color_builtin,	TYPE_RECT2                 : _color_builtin,
	TYPE_RECT2I                : _color_builtin,	TYPE_VECTOR3               : _color_builtin,
	TYPE_VECTOR3I              : _color_builtin,	TYPE_TRANSFORM2D           : _color_builtin,
	TYPE_VECTOR4               : _color_builtin,	TYPE_VECTOR4I              : _color_builtin,
	TYPE_PLANE                 : _color_builtin,	TYPE_QUATERNION            : _color_builtin,
	TYPE_AABB                  : _color_builtin,	TYPE_BASIS                 : _color_builtin,
	TYPE_TRANSFORM3D           : _color_builtin,	TYPE_PROJECTION            : _color_builtin,
	TYPE_COLOR                 : _color_builtin,	TYPE_STRING_NAME           : _color_string,
	TYPE_NODE_PATH             : _color_string,		TYPE_RID                   : _color_number,
	TYPE_OBJECT                : _color_object,		TYPE_CALLABLE              : _color_builtin,
	TYPE_SIGNAL                : _color_builtin,	TYPE_DICTIONARY            : _color_builtin,
	TYPE_ARRAY                 : _color_builtin,	TYPE_PACKED_BYTE_ARRAY     : _color_builtin,
	TYPE_PACKED_INT32_ARRAY    : _color_builtin,	TYPE_PACKED_INT64_ARRAY    : _color_builtin,
	TYPE_PACKED_FLOAT32_ARRAY  : _color_builtin,	TYPE_PACKED_FLOAT64_ARRAY  : _color_builtin,
	TYPE_PACKED_STRING_ARRAY   : _color_builtin,	TYPE_PACKED_VECTOR2_ARRAY  : _color_builtin,
	TYPE_PACKED_VECTOR3_ARRAY  : _color_builtin,	TYPE_PACKED_COLOR_ARRAY    : _color_builtin,
}

const _FONT_SIZE_PROPS:Array[String] = [
	"theme_override_font_sizes/normal_font_size",
	"theme_override_font_sizes/bold_font_size",
	"theme_override_font_sizes/italics_font_size",
	"theme_override_font_sizes/bold_italics_font_size",
	"theme_override_font_sizes/mono_font_size",
]

var _lines:Array[Dictionary]
var _grouped_lines:Dictionary
var _nodes:Dictionary
var _node_properties:Dictionary
var _bms: Dictionary


var _text_keys:String
var _text_vals:String
var _bm_cache: Dictionary

var _info_visible    := false

var _size_update_interval := 5.0
var _size_update_timer := 0.0

@onready var _ui_base: TabContainer = %ui_base
@onready var _container: MarginContainer = %container
@onready var _label_keys: RichTextLabel = %label_keys
@onready var _label_vals: RichTextLabel = %label_vals


func _ready() -> void:
	_init_config()
	_init_text_sizes()
	_init_background()

	set_enabled(_info_visible, true)


func _process(delta: float) -> void:
	assert(_info_visible == true)

	_process_lines.call_deferred()
	_process_grouped_lines.call_deferred()
	_process_node_properties.call_deferred()
	_finish_processing.call_deferred()
	_clean_up.call_deferred()

	# prevent the panel size from twitching when displaying fluctuating values
	_size_update_timer -= delta
	if _size_update_timer <= 0:
		_size_update_timer = _size_update_interval
		_label_vals.custom_minimum_size = Vector2.ZERO
	else:
		_label_vals.custom_minimum_size = _label_vals.size
	#Toolbox.print("size_update_timer", _size_update_timer, 2)


func _init_background() -> void:
	var style:StyleBoxFlat = _ui_base.get("theme_override_styles/panel")
	if not _draw_background:
		style.bg_color = Color.TRANSPARENT
	else:
		style.bg_color = _bg_color

	if not _draw_border:
		style.border_color = Color.TRANSPARENT
		return

	style.border_color = _border_color
	style.border_width_right = _border_width
	style.border_width_bottom = _border_width



func _init_config() -> void:
	var data: Resource = load("res://addons/gd_dev_toolbox/shared.gd")
	var config: Resource = data.get_config()
	if not config: return

	layer                   = config.info_tool_layer

	_text_size               = config.text_size
	_def_float_precision     = config.float_precision
	_outline_size            = config.outline_size
	_draw_background         = config.draw_background
	_draw_border             = config.draw_border
	_bg_color                = config.background_color
	_border_width            = config.border_width
	_border_color            = config.border_color
	_color_null              = config.null_color
	_color_number            = config.number_color
	_color_string            = config.string_color
	_color_bool              = config.bool_color
	_color_builtin           = config.builtin_color
	_color_object            = config.object_color
	_color_key               = config.key_color
	_color_group             = config.group_color
	_def_bm_smoothing        = config.smoothing
	_bm_time_units           = config.time_units
	_bm_precision            = config.decimal_precision
	_max_smoothing           = config.max_smoothing



func _finish_processing() -> void:
	_label_keys.text = _tag_outline_color(_tag_outline_size(_text_keys, _outline_size), Color.BLACK)
	_label_vals.text = _tag_outline_color(_tag_outline_size(_text_vals, _outline_size), Color.BLACK)


func _clean_up() -> void:
	_text_keys = ""
	_text_vals = ""
	_lines.clear()
	_grouped_lines.clear()
	#_nodes.clear()
	_node_properties.clear()


func _process_lines() -> void:
	for line:Dictionary in _lines:
		_add_line(line)


func _process_grouped_lines() -> void:
	for group_name:String in _grouped_lines:
		_text_keys += '\n' + _SPACER + _tag_color(group_name, _color_group) + _SPACER + '\n'
		#_text_vals += '\n' + _tag_bgcolor(group_name, color_group_bg) + '\n'
		_text_vals += '\n\n'

		for line:Dictionary in _grouped_lines[group_name]:
			_add_line(line, _GROUP_PREFIX)


func _process_node_properties() -> void:
	for node:Object in _nodes:
		if node == null: continue

		_text_keys += '\n' + _SPACER + _tag_color(node.name, _color_object) + _SPACER + '\n'
		_text_vals += '\n\n'

		for prop:Dictionary in _nodes[node].values():
			var line := {
				key = prop.name,
				val = node.get(prop.name),
				fp = prop.fp,
			}
			_add_line(line, _GROUP_PREFIX)

		if node in _node_properties:
			for line:Dictionary in _node_properties[node]:
				_add_line(line, _NODE_PROP_PREFIX)


func _init_text_sizes() -> void:
	for prop in _FONT_SIZE_PROPS:
		_label_keys.set(prop, _text_size)
		_label_vals.set(prop, _text_size)


func _add_line(line:Dictionary, prefix:="") -> void:
	var key:String  = line.key
	var val:Variant = line.val
	var fp:String   = str(int(line.fp))

	_text_keys += _SPACER + prefix + _tag_color(key, _color_key) + _SPACER + '\n'

	#if val != null:
	var tp := typeof(val)
	#_text_vals += _SPACER

	if tp == TYPE_FLOAT:
		_text_vals += _SPACER + _tag_color(("%." + fp + "f") % [val], _colors_lookup[tp]) + _SPACER
	else:
		_text_vals += _SPACER + _tag_color(str(val), _colors_lookup[tp]) + _SPACER

	_text_vals += '\n'


func _tag_color(text:String, color:Color) -> String:
	#return '[color="' + color.to_html(false) + '"]' + text + "[/color]"
	return "[color=%s]%s[/color]" % [color.to_html(false), text]

func _tag_outline_color(text:String, color:Color) -> String:
	#return "[outline_color=" + color.to_html(false) + "]" + text + "[/outline_color]"
	return "[outline_color=%s]%s[/outline_color]" % [color.to_html(false), text]

func _tag_outline_size(text:String, size:int) -> String:
	#return "[outline_size=" + str(size) + "]" + text + "[/outline_size]"
	return "[outline_size=%d]%s[/outline_size]" % [size, text]




func toggle()  -> void: set_enabled(not _info_visible)
#func enable()  -> void: set_enabled(true)
#func disable() -> void: set_enabled(false)
func set_enabled(vis:bool, force:=false) -> void:
	if vis == _info_visible and not force: return
	_info_visible = vis
	_ui_base.visible = _info_visible

	# this fixes the TabContainer's panel failing to resize to the label's size
	# when it becomes visible again
	await get_tree().process_frame
	_container.visible = _info_visible
	set_process(_info_visible)







func _create_line(key:String, val:Variant, fp:float) -> Dictionary:
	return { key=key, val=val, fp=fp }


func print(key:String, val:Variant=null, fp:=_def_float_precision) -> void:
	if not _info_visible: return
	var line := _create_line(key, val, fp)
	_lines.append(line)


func print_grouped(group_name:String, key:String, val:Variant=null, fp:=_def_float_precision) -> void:
	if not _info_visible: return

	var line := _create_line(key, val, fp)

	if not group_name in _grouped_lines:
		var arr:Array[Dictionary] = []
		_grouped_lines[group_name] = arr

	_grouped_lines[group_name].append(line)


func print_prop(node:Object, key:String, val:Variant=null, fp:=_def_float_precision) -> void:
	if not _info_visible: return

	var line := _create_line(key, val, fp)

	if not node in _node_properties:
		_node_properties[node] = []
	_node_properties[node].append(line)


func is_registered(node:Object) -> bool:
	return node in _nodes


func register(node:Object, property_names:Array, fp:=2) -> void:
	if not node in _nodes:
		_nodes[node] = {}

	for pname:String in property_names:
		assert(pname is String)
		var prop := { name=pname, fp=fp }
		_nodes[node][pname] = prop


func unregister(node:Object, property_name:="") -> void:
	if not node in _nodes: return

	if property_name != "":
		_nodes[node].erase(property_name)
		if not _nodes[node].size():
			_nodes.erase(node)
	else:
		_nodes.erase(node)


@warning_ignore("shadowed_variable_base_class")
func _get_cached(name:String) -> Dictionary:
	if not name in _bm_cache:
		_bm_cache[name] = {
			frames = 0,
			time = 0,
			history = [],
		}
	return _bm_cache[name]

#func _count_frame(cached:Dictionary) -> void:
	#cached.frames += 1
	#if cached.frames > 500:
		#cached.frames = 1
		#cached.time = 0


@warning_ignore("shadowed_variable_base_class")
func print_bm(name:String, fn:Callable, options:Variant=null) -> Variant:
	#smoothing:=_def_bm_smoothing, precision:=_bm_precision, time_units:=_bm_time_units
#) -> float:
	if not _info_visible:
		fn.call()
		return

	var t1:float = Time.get_ticks_msec()
	fn.call()
	var t2:float = (Time.get_ticks_msec() - t1)

	var smoothing: int  = _def_bm_smoothing
	var precision: int  = _bm_precision
	var time_units: int = _bm_time_units
	if options:
		if "smoothing" in options: smoothing  = clamp(options.smoothing, 0, _max_smoothing)
		if "precision" in options: precision  = clamp(options.precision, 0, _max_bm_precision)
		if "units"     in options: time_units = clamp(options.units, 0, 2)

	var cached := _get_cached(name)
	var avg:float = t2 # = cached.time/cached.frames

	if smoothing > 1:
		cached.time += t2
		if cached.history.size() > _def_bm_smoothing:
			cached.time -= cached.history.pop_front()
		cached.history.append(t2)
		avg = cached.time/cached.history.size()

	var times_str:String = "%." + str(precision) + "f"
	match time_units:
		SEC:  times_str = (times_str + " s") % [avg/1000]
		MSEC: times_str = (times_str + " ms") % [avg]

	print_grouped("Benchmarks", name, times_str)

	#return ("%s: " + times_str) % [name]
	return t2


func benchmark(bm_name:StringName, max_benchmarks:int, iterations:int, fn:Callable) -> void:
	#var info = getinfo(2, "nSl")
	var bm: Dictionary
	if not bm_name in _bms:
		_bms[bm_name] = {
			time           = 0.0,
			total_time     = 0.0,
			frames         = 0,
			total_frames   = 0,
			benchmarks     = 0,
			total_bms      = 0,
		}
	bm = _bms[bm_name]

	var t1:float = Time.get_ticks_msec()
	fn.call()
	var t2:float = (Time.get_ticks_msec() - t1)

	bm.time   += t2
	bm.frames += 1

	if bm.frames % iterations == 0:
		if bm.benchmarks == 0:
			print("---------------------------------------------------------------------------------")
		bm.total_frames += bm.frames
		bm.total_time   += bm.time
		var average: float = bm.time / float(bm.frames)

		var bm_num      := "(%s/%d) %s" % [
				str(bm.benchmarks+1).lpad(str(max_benchmarks).length(), ' '),
				max_benchmarks,
				bm_name,
			]

		#var filename    := "[%s:%d]" % [info.short_src:filename(), info.currentline]
		var averaging   := "%.3f ms  (%.3f s)" % [average, average/1000]
		var total_times := "%.3f ms  (%.3f s)" % [bm.time, bm.time/1000]

		var output1 = "● %s  |  time/iteration:  %s  |  total time (%s iterations):  %s" % [bm_num, averaging, iterations, total_times]
		print(output1)

		bm.benchmarks += 1
		bm.total_bms  += 1

		if bm.benchmarks % max_benchmarks == 0:
			var total_average: float = bm.total_time / float(bm.total_frames)
			var output2 := "\n●  %s  >>>  total average:  %.6f ms/iter  (%.6f s/iter)\n" % [
				bm_name,
				total_average,
				total_average/1000
			]

			print(output2)
			#print("---------------------------------------------------------------------------------\n")
			bm.benchmarks = 0
			bm.total_bms = 0
			bm.total_frames += bm.frames
			bm.total_time   += bm.time


		bm.time = 0
		bm.frames = 0
