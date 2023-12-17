extends Node


const _DEF_KEYS:Array[int] = [KEY_BACKSLASH, KEY_ASCIITILDE]

var _info_input_checker_func:Callable
var _drawing_input_checker_func:Callable

@onready var _it:CanvasLayer = $info_tool



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _ready() -> void:
	_init_input_actions()


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return
	_info_input_checker_func.call(event)


func _init_input_actions() -> void:
	if InputMap.has_action("dev_tools_info"):
		_info_input_checker_func = \
				func(event:InputEventKey) -> void:
					if event.is_action_pressed("dev_tools_info"):
						toggle_info()
	else:
		_info_input_checker_func = \
				func(event:InputEventKey) -> void:
					var mods_ok := not (event.ctrl_pressed or event.shift_pressed or event.alt_pressed)

					if event.keycode in _DEF_KEYS and event.pressed \
					and not event.echo and mods_ok:
						toggle_info()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func toggle_info()  -> void: _it.toggle()
func enable_info()  -> void: _it.set_info_enabled(true)
func disable_info() -> void: _it.set_info_enabled(false)


func print(key:String, val:Variant=null, fp:int=_it.FLOAT_PRECISION) -> void:
	_it.print(key, val, fp)


func print_grouped(group_name:String, key:String, val:Variant=null, fp:int=_it.FLOAT_PRECISION) -> void:
	_it.print_grouped(group_name, key, val, fp)
