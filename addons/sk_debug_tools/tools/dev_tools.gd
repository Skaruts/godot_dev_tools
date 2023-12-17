extends Node

var data: Node = load("res://addons/sk_debug_tools/data.gd").new()

var _info_input_checker_func:Callable
var _drawing_input_checker_func:Callable


@onready var _it:CanvasLayer = $info_tool



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _enter_tree() -> void:

	# TODO: should I do this automatically, or should I leave it for users to
	# decide whether they want the config file or not?

	#if not FileAccess.file_exists(data.DT_SETTINGS_PATH):
		#var dtc := DevToolsConfig.new()
		#ResourceSaver.save(dtc, data.DT_SETTINGS_PATH)
	pass

func _ready() -> void:
	#print(_ready)
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

					if event.keycode in data.DEF_KEYS and event.pressed \
					and not event.echo and mods_ok:
						toggle_info()




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func toggle_info()  -> void: _it.toggle()
func enable_info()  -> void: _it.set_info_enabled(true)
func disable_info() -> void: _it.set_info_enabled(false)


func print(key:String, val:Variant=null, fp:int=_it.default_float_precision) -> void:
	_it.print(key, val, fp)


func print_grouped(group_name:String, key:String, val:Variant=null, fp:int=_it.default_float_precision) -> void:
	_it.print_grouped(group_name, key, val, fp)
