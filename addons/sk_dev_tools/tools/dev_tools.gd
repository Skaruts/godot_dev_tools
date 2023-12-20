extends Node


var _data: Resource = load("res://addons/sk_dev_tools/shared.gd")

@onready var _it:CanvasLayer = $info_tool



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _enter_tree() -> void:
	# TODO: should I create a config file automatically, or should I
	# leave it to the users to decide whether they want the config file or not?
	# _data.check_config()
	pass


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return

	if InputMap.has_action("dev_tools_info"):
		if event.is_action_pressed("dev_tools_info"):
			toggle_info()
	else:
		var mods_ok:bool = not (event.ctrl_pressed or event.shift_pressed or event.alt_pressed)
		if event.keycode in _data.DEF_KEYS \
		and event.pressed and not event.echo and mods_ok:
			toggle_info()

	if InputMap.has_action("dev_tools_drawing"):
		if event.is_action_pressed("dev_tools_drawing"):
			DevTools2D.toggle()
			DevTools3D.toggle()
	else:
		var mods_ok :bool = event.ctrl_pressed          \
			   				and not event.shift_pressed \
			   				and not event.alt_pressed

		if event.keycode in _data.DEF_KEYS \
		and event.pressed and not event.echo and mods_ok:
			DevTools2D.toggle()
			DevTools3D.toggle()


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func toggle_info()  -> void: _it.toggle()
func enable_info()  -> void: _it.set_enabled(true)
func disable_info() -> void: _it.set_enabled(false)
func set_info_enabled(enabled:bool) -> void:
	_it.set_enabled(enabled)

func toggle_drawing()  -> void:
	DevTools2D.toggle()
	DevTools3D.toggle()

func enable_drawing()  -> void:
	DevTools2D.set_enabled(true)
	DevTools3D.set_enabled(true)

func disable_drawing() -> void:
	DevTools2D.set_enabled(false)
	DevTools3D.set_enabled(false)

func set_drawing_enabled(enabled:bool) -> void:
	DevTools2D.set_enabled(enabled)
	DevTools3D.set_enabled(enabled)


func print(key:String, val:Variant=null, fp:int=_it._def_float_precision) -> void:
	_it.print(key, val, fp)


func print_grouped(group_name:String, key:String, val:Variant=null,
				   fp:int=_it._def_float_precision) -> void:
	_it.print_grouped(group_name, key, val, fp)


func print_prop(node:Object, key:String, val:Variant=null,
				fp:float = _it._def_float_precision) -> void:
	_it.print_prop(node, key, val, fp)


func is_registered(node:Object) -> bool:
	return _it.is_registered(node)


func register(node:Object, values:Array) -> void:
	_it.register(node, values)


func unregister(node:Object, property_name:="") -> void:
	_it.unregister(node, property_name)


# TODO: Must find a better way to relay this to users
# As well as the rest of this API...
enum {
	SEC,
	MSEC,
}

#@warning_ignore("shadowed_variable_base_class")
#func bm(name:String, f:Callable, smoothing:int = _it._def_bm_smoothing,
		#precision:float = _it._bm_precision_secs
		#, time_units:float = _it._bm_time_units) -> float:
	#return _it.bm(name, f, smoothing, precision, time_units)


@warning_ignore("shadowed_variable_base_class")
func print_bm(name:String, f:Callable, options:Variant=null) -> Variant:
	return _it.print_bm(name, f, options)


func benchmark(bm_name:StringName, num_benchmarks:int, num_iterations:int, fn:Callable) -> void:
	_it.benchmark(bm_name, num_benchmarks, num_iterations, fn)

