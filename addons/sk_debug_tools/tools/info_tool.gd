extends CanvasLayer


var text_size       := 16
var default_float_precision :int = 2
var outline_size    := 10

var draw_background := true
var draw_border     := true
var bg_color        := Color("1a1a1a99")
var border_width    := 1
var border_color    := Color("ffffff5d")

var color_null    := Color.FUCHSIA
var color_number  := Color(0.81, 0.64, 0.99)
var color_string  := Color(1, 0.90, 0.66)
var color_bool    := Color(1, 0.72, 0.26)
var color_builtin := Color(0.74, 0.84, 1)
var color_object  := Color(0.30, 0.86, 0.30)

var color_key     := Color.LIGHT_GRAY
var color_group   := Color(1, 0.37, 0.37)
#var color_group_bg := Color.GREEN


const GROUP_PREFIX := "    "
const NODE_PROP_PREFIX := "    "
const _SPACER := ' ' # this prevents outlines getting cut off at the edges of the labels

var _colors_lookup := {
	TYPE_NIL                   : color_null,		TYPE_BOOL                  : color_bool,
	TYPE_INT                   : color_number,		TYPE_FLOAT                 : color_number,
	TYPE_STRING                : color_string,		TYPE_VECTOR2               : color_builtin,
	TYPE_VECTOR2I              : color_builtin,		TYPE_RECT2                 : color_builtin,
	TYPE_RECT2I                : color_builtin,		TYPE_VECTOR3               : color_builtin,
	TYPE_VECTOR3I              : color_builtin,		TYPE_TRANSFORM2D           : color_builtin,
	TYPE_VECTOR4               : color_builtin,		TYPE_VECTOR4I              : color_builtin,
	TYPE_PLANE                 : color_builtin,		TYPE_QUATERNION            : color_builtin,
	TYPE_AABB                  : color_builtin,		TYPE_BASIS                 : color_builtin,
	TYPE_TRANSFORM3D           : color_builtin,		TYPE_PROJECTION            : color_builtin,
	TYPE_COLOR                 : color_builtin,		TYPE_STRING_NAME           : color_string,
	TYPE_NODE_PATH             : color_string,		TYPE_RID                   : color_number,
	TYPE_OBJECT                : color_object,		TYPE_CALLABLE              : color_builtin,
	TYPE_SIGNAL                : color_builtin,		TYPE_DICTIONARY            : color_builtin,
	TYPE_ARRAY                 : color_builtin,		TYPE_PACKED_BYTE_ARRAY     : color_builtin,
	TYPE_PACKED_INT32_ARRAY    : color_builtin,		TYPE_PACKED_INT64_ARRAY    : color_builtin,
	TYPE_PACKED_FLOAT32_ARRAY  : color_builtin,		TYPE_PACKED_FLOAT64_ARRAY  : color_builtin,
	TYPE_PACKED_STRING_ARRAY   : color_builtin,		TYPE_PACKED_VECTOR2_ARRAY  : color_builtin,
	TYPE_PACKED_VECTOR3_ARRAY  : color_builtin,		TYPE_PACKED_COLOR_ARRAY    : color_builtin,
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

var _text_keys:String
var _text_vals:String

var _info_visible    := false
@onready var _ui_base: TabContainer = %ui_base
@onready var _container: MarginContainer = %container
@onready var _label_keys: RichTextLabel = %label_keys
@onready var _label_vals: RichTextLabel = %label_vals


func _ready() -> void:
	_init_config()
	_init_text_sizes()
	_init_background()

	set_info_enabled(_info_visible, true)


func _process(_delta: float) -> void:
	#if not _info_visible: return
	assert(_info_visible == true)
	_process_lines.call_deferred()
	_process_grouped_lines.call_deferred()
	_process_node_properties.call_deferred()
	_finish_processing.call_deferred()
	_clean_up.call_deferred()


func _init_background() -> void:
	var style:StyleBoxFlat = _ui_base.get("theme_override_styles/panel")
	if not draw_background:
		#_ui_base.set("theme_override_styles/panel", StyleBoxEmpty.new())
		style.bg_color = Color.TRANSPARENT
		#return
	else:
		style.bg_color = bg_color

	if not draw_border:
		style.border_color = Color.TRANSPARENT
		return

	style.border_color = border_color
	style.border_width_right = border_width
	style.border_width_bottom = border_width



func _init_config() -> void:
	var data: Node = load("res://addons/sk_debug_tools/data.gd").new()

	if not FileAccess.file_exists(data.DT_SETTINGS_PATH):
		return

	var config := load(data.DT_SETTINGS_PATH)

	layer                   = config.info_tool_layer

	text_size               = config.text_size
	default_float_precision = config.default_float_precision
	outline_size            = config.outline_size
	draw_background         = config.draw_background
	draw_border             = config.draw_border
	bg_color                = config.background_color
	border_width            = config.border_width
	border_color            = config.border_color
	color_null              = config.null_color
	color_number            = config.number_color
	color_string            = config.string_color
	color_bool              = config.bool_color
	color_builtin           = config.builtin_color
	color_object            = config.object_color
	color_key               = config.key_color
	color_group             = config.group_color
	#color_group_bg         = #color_group_bg


func _finish_processing() -> void:
	_label_keys.text = _tag_outline_color(_tag_outline_size(_text_keys, outline_size), Color.BLACK)
	_label_vals.text = _tag_outline_color(_tag_outline_size(_text_vals, outline_size), Color.BLACK)


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
		_text_keys += '\n' + _SPACER + _tag_color(group_name, color_group) + _SPACER + '\n'
		#_text_vals += '\n' + _tag_bgcolor(group_name, color_group_bg) + '\n'
		_text_vals += '\n\n'

		for line:Dictionary in _grouped_lines[group_name]:
			_add_line(line, GROUP_PREFIX)


func _process_node_properties() -> void:
	for node in _nodes:
		if node == null: continue

		_text_keys += '\n' + _SPACER + _tag_color(node.name, color_object) + _SPACER + '\n'
		_text_vals += '\n\n'

		for prop in _nodes[node].values():
			var line := {
				key = prop.name,
				val = node.get(prop.name),
				fp = prop.fp,
			}
			_add_line(line, GROUP_PREFIX)

		if node in _node_properties:
			for line in _node_properties[node]:
				_add_line(line, NODE_PROP_PREFIX)


func _init_text_sizes() -> void:
	for prop in _FONT_SIZE_PROPS:
		_label_keys.set(prop, text_size)
		_label_vals.set(prop, text_size)


func _add_line(line:Dictionary, prefix:="") -> void:
	var key:String  = line.key
	var val:Variant = line.val
	var fp:String   = str(int(line.fp))

	_text_keys += _SPACER + prefix + _tag_color(key, color_key) + _SPACER + '\n'

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




func toggle()  -> void: set_info_enabled(not _info_visible)
#func enable()  -> void: set_info_enabled(true)
#func disable() -> void: set_info_enabled(false)
func set_info_enabled(vis:bool, force:=false) -> void:
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


func print(key:String, val:Variant=null, fp:=default_float_precision) -> void:
	if not _info_visible: return
	var line := _create_line(key, val, fp)
	_lines.append(line)


func print_grouped(group_name:String, key:String, val:Variant=null, fp:=default_float_precision) -> void:
	if not _info_visible: return

	var line := _create_line(key, val, fp)

	if not group_name in _grouped_lines:
		var arr:Array[Dictionary] = []
		_grouped_lines[group_name] = arr

	_grouped_lines[group_name].append(line)


func print_prop(node:Object, key:String, val:Variant=null, fp:=default_float_precision) -> void:
	if not _info_visible: return

	var line := _create_line(key, val, fp)

	if not node in _node_properties:
		_node_properties[node] = []
	_node_properties[node].append(line)


func is_registered(node:Object) -> bool:
	return node in _nodes


func register(node:Object, property_name:String, fp:=2) -> void:
	if not node in _nodes:
		_nodes[node] = {}

	var prop := {
		name = property_name,
		fp = fp,
	}
	_nodes[node][property_name] = prop


func register_batch(node:Object, property_names:Array, fp:=2) -> void:
	for n in property_names:
		assert(n is String)
		register(node, n, fp)


func unregister(node, property_name:="") -> void:
	if not node in _nodes: return

	if property_name != "":
		_nodes[node].erase(property_name)
		if not _nodes[node].size():
			_nodes.erase(node)
	else:
		_nodes.erase(node)
