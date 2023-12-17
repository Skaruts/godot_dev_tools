extends CanvasLayer


const text_size       := 20
const FLOAT_PRECISION :int = 2
const outline_size    := 10

const draw_background := true
const draw_border     := true
const bg_color        := Color("1a1a1a99")
const border_width    := 1
const border_color    := Color("ffffff5d")

const color_null    := Color.FUCHSIA
const color_number  := Color(0.81, 0.64, 0.99)
const color_string  := Color(1, 0.90, 0.66)
const _color_bool   := Color(1, 0.72, 0.26)
const color_builtin := Color(0.74, 0.84, 1)
const color_object  := Color(0.30, 0.86, 0.30)

const color_key     := Color.LIGHT_GRAY
const color_group   := Color(1, 0.37, 0.37)
#const color_group_bg := Color.GREEN





const GROUP_PREFIX := "      "
const _SPACER := ' ' # this prevents outlines getting cut off at the edges of the labels

const _COLORS_LOOKUP := {
	TYPE_NIL                   : color_null,		TYPE_BOOL                  : _color_bool,
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

var _text_keys:String
var _text_vals:String

var _info_visible    := false

@onready var _ui_base: TabContainer = %ui_base
@onready var _container: MarginContainer = %container
@onready var _label_keys: RichTextLabel = %label_keys
@onready var _label_vals: RichTextLabel = %label_vals


func _ready() -> void:
	_init_text_sizes()
	_init_background()

	set_info_enabled(_info_visible, true)


#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("toggle_debug_info"):
		#toggle()
		#get_viewport().set_input_as_handled()


func _process(_delta: float) -> void:
	#if not _info_visible: return
	assert(_info_visible == true)
	_process_lines.call_deferred()
	_process_grouped_lines.call_deferred()
	_finish_processing.call_deferred()
	_clean_up.call_deferred()


func _init_background() -> void:
	if not draw_background:
		_ui_base.set("theme_override_styles/panel", StyleBoxEmpty.new())
		return

	var style:StyleBoxFlat = _ui_base.get("theme_override_styles/panel")
	style.bg_color = bg_color

	if not draw_border:
		style.border_color = Color.TRANSPARENT
		return

	style.border_color = border_color
	style.border_width_right = border_width
	style.border_width_bottom = border_width




func _finish_processing() -> void:
	_label_keys.text = _tag_outline_color(_tag_outline_size(_text_keys, outline_size), Color.BLACK)
	_label_vals.text = _tag_outline_color(_tag_outline_size(_text_vals, outline_size), Color.BLACK)


func _clean_up() -> void:
	_text_keys = ""
	_text_vals = ""
	_lines.clear()
	_grouped_lines.clear()


func _process_lines() -> void:
	for line:Dictionary in _lines:
		_add_line(line)


func _process_grouped_lines() -> void:
	for group_name:String in _grouped_lines:
		_text_keys += '\n' + _SPACER + _tag_color(group_name, color_group) + '\n'
		#_text_vals += '\n' + _tag_bgcolor(group_name, color_group_bg) + '\n'
		_text_vals += '\n\n'

		for line:Dictionary in _grouped_lines[group_name]:
			_add_line(line, GROUP_PREFIX)




func _init_text_sizes() -> void:
	for prop in _FONT_SIZE_PROPS:
		_label_keys.set(prop, text_size)
		_label_vals.set(prop, text_size)


func _add_line(line:Dictionary, prefix:="") -> void:
	var key:String  = line.key
	var val:Variant = line.val
	var fp:String   = str(int(line.fp))

	_text_keys += _SPACER + prefix + _tag_color(key, color_key) + '\n'

	#if val != null:
	var tp := typeof(val)
	_text_vals += _SPACER

	if tp == TYPE_FLOAT:
		_text_vals += _SPACER + _tag_color(("%." + fp + "f") % [val], _COLORS_LOOKUP[tp])
	else:
		_text_vals += _SPACER + _tag_color(str(val), _COLORS_LOOKUP[tp])

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


func print(key:String, val:Variant=null, fp:=FLOAT_PRECISION) -> void:
	if not _info_visible: return
	var line := _create_line(key, val, fp)
	_lines.append(line)


func print_grouped(group_name:String, key:String, val:Variant=null, fp:=FLOAT_PRECISION) -> void:
	if not _info_visible: return

	var line := _create_line(key, val, fp)

	if not group_name in _grouped_lines:
		var arr:Array[Dictionary] = []
		_grouped_lines[group_name] = arr

	_grouped_lines[group_name].append(line)



