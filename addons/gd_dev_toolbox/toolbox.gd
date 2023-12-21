extends Node

##
##
##




var _data: Resource = load("res://addons/gd_dev_toolbox/shared.gd")

@onready var _it:CanvasLayer = $info_tool



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		LOOP

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
func _enter_tree() -> void:
	# TODO: should I create a config file automatically, or should I
	# leave it for users to decide to create one if they want?
	# _data.validate_or_create_config()
	pass


func _input(event: InputEvent) -> void:
	if not event is InputEventKey: return

	if InputMap.has_action("dev_tools_info"):
		if event.is_action_pressed("dev_tools_info"):
			monitoring_toggle()
	else:
		var mods_ok:bool = not (event.ctrl_pressed or event.shift_pressed or event.alt_pressed)
		if event.keycode in _data.DEF_KEYS \
		and event.pressed and not event.echo and mods_ok:
			monitoring_toggle()

	if InputMap.has_action("dev_tools_drawing"):
		if event.is_action_pressed("dev_tools_drawing"):
			Toolbox2D.toggle()
			Toolbox3D.toggle()
	else:
		var mods_ok :bool = event.ctrl_pressed          \
			   				and not event.shift_pressed \
			   				and not event.alt_pressed

		if event.keycode in _data.DEF_KEYS \
		and event.pressed and not event.echo and mods_ok:
			Toolbox2D.toggle()
			Toolbox3D.toggle()


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#		PUBLIC API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
## Toggle the monitoring panel on/off
func monitoring_toggle()  -> void: _it.toggle()

## Enable the monitoring panel
func monitoring_enable()  -> void: _it.set_enabled(true)

## Disable the monitoring panel
func monitoring_disable() -> void: _it.set_enabled(false)

## Set the monitoring panel on or off
func monitoring_set_enabled(enabled:bool) -> void:
	_it.set_enabled(enabled)


## Toggle drawing on/off
func drawing_toggle()  -> void:
	Toolbox2D.toggle()
	Toolbox3D.toggle()

## Enable drawing
func drawing_enable()  -> void:
	Toolbox2D.set_enabled(true)
	Toolbox3D.set_enabled(true)

## Disable drawing
func drawing_disable() -> void:
	Toolbox2D.set_enabled(false)
	Toolbox3D.set_enabled(false)

## Set drawing on or off
func drawing_set_enabled(enabled:bool) -> void:
	Toolbox2D.set_enabled(enabled)
	Toolbox3D.set_enabled(enabled)


## Displays a key/value pair in the info panel. If the value is a float you can
## optionally pass in your desired float precision.
func print(key:String, val:Variant, fp:int=_it._def_float_precision) -> void:
	_it.print(key, val, fp)


## The same as [method print], but displays the lines together
## as a group.
func print_grouped(group_name:String, key:String, val:Variant=null,
				   fp:int=_it._def_float_precision) -> void:
	_it.print_grouped(group_name, key, val, fp)


## The same as [method print_grouped], but uses an object's name
## as the group, with a different color.
func print_prop(object:Object, key:String, val:Variant,
				fp:float = _it._def_float_precision) -> void:
	_it.print_prop(object, key, val, fp)

## Check if [param object] is registered.
func is_registered(object:Object) -> bool:
	return _it.is_registered(object)


## Registers the properties of [param object] listed in [param property_names]
## in the info panel, such that the panel will automatically update them
## every frame. An aditional float precision [param fp] can be passed in, if any of the
## properties are floats. [br]
## [br]
## This function should be called only once in [annotation _init],
## [annotation _ready] or [annotation _enter_tree], and not every frame. [br]
## [br]
## Toolbox doesn't automatically detect when nodes or objects are freed or
## destroyed, so any objects using this feature should call
## [annotation Toolbox.unregister] on [annotation _exit_tree] or before being deleted.
func register(object:Object, property_names:Array, fp:float=_it._def_float_precision) -> void:
	_it.register(object, property_names)


## Unregisters [param property_name]. If no property name is given, it
## will unregister the [param object] entirely.
func unregister(object:Object, property_name:="") -> void:
	_it.unregister(object, property_name)


# TODO: Must find a better way to relay this to users
# As well as the rest of this API...
enum TimeUnits {
	## Seconds
	SEC,
	## Milliseconds
	MSEC,
}

#@warning_ignore("shadowed_variable_base_class")
#func bm(name:String, f:Callable, smoothing:int = _it._def_bm_smoothing,
		#precision:float = _it._bm_precision_secs
		#, time_units:float = _it._bm_time_units) -> float:
	#return _it.bm(name, f, smoothing, precision, time_units)


## Tracks the execution time of function [param fn]. Works the
## same way as [method benchmark], but only reports a single iteration,
## printed to the monitoring panel under the benchmarks group.[br]
## [br]
## Optionally, you can pass in an [param options] dictionary, containing a few
## settings: [br]
## [br]
##  - [param smoothing] ([int]): how much smoothing to apply to the report. This prevents numbers
## that fluctuate too fast from being unreadable, at the expense of accuracy. Higher value means
## less twitchiness and less accuracy. ([param Default = 15]) [br]
## [br]
##  - [param precision] ([int]): the floating point precision to be used in the results. ([param Default = 4]) [br]
## [br]
##  - [param units] ([member TimeUnits]): whether to use seconds or milliseconds. ([param Default = TimeUnits.MSEC]) [br]
@warning_ignore("shadowed_variable_base_class")
func print_bm(name:String, fn:Callable, options:Variant=null) -> Variant:
	return _it.print_bm(name, fn, options)

## Benchmarks the function [param fn]. Performs [param num_benchmarks] for
## [param num_iterations] each, and reports the results to the standard output
## under the name [param bm_name], as well as the monitoring panel's
## benchmarks group. After [param num_benchmarks] it outputs a total average
## of the benchmarks. [br]
## [br]
## When benchmarking very quick tasks, you may want to set
## [param num_iterations] quite high, or else the reports will be printed out
## too fast to read. [br]
## [br]
## [b]Note:[/b] this function doesn't run [param fn] multiple times per call.
## It runs it once per call, but accumulates the relevant information during
## each call, so it can eventually report the averaged results. [br]
## [br]
## [b]Examples:[/b][br]
## [br]
## To benchmark a piece of code, put the code in a lambda that's passed in
## as the [param fn] argument:
## [codeblock]
## Toolbox.benchmark("Timing for loop", 10, 10000, func():
##     for i in 100000:
##         x = 10
## )
## [/codeblock]
## You can also use it to benchmark an entire function. Rename the original
## function, and replace it with one that wraps it in a lambda:
## [codeblock]
## func foo(a, b):
##     Toolbox.benchmark(str(_foo), 10, 10000, func():
##         _foo(a, b)
##     )
##
## func _foo(a, b):
##     # (...)
## [/codeblock]
## You can name the benchmarks whatever you want, but passing in the
## stringified current function, as in the previous example, is a convenient
## way to make it easy to tell where they're coming from.
func benchmark(bm_name:String, num_benchmarks:int, num_iterations:int, fn:Callable) -> void:
	_it.benchmark(bm_name, num_benchmarks, num_iterations, fn)

