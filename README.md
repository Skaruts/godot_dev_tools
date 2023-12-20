# Godot Dev Toolbox

A few handy tools for general development and debugging that I've developed over time and gathered up into a single easier to use addon. It provides a panel for easily monitoring variables, and a few functions for quick benchmarking, and 2D and 3D drawing.

Toolbox gets around Godot's lack of support for line thickness in 3D by using stretched 3D shapes to make thick 3D lines.


## Usage:

There are three autoloads added by this addon:

- `Toolbox`    - for text information and quick benchmarking
- `Toolbox2D`  - for 2D shape drawing
- `Toolbox3D`  - for 3D shape drawing

You can use them to display information in the way you find most suitable.

### Input Actions

By default, Toolbox uses hardcoded key bindings, but it supports some input actions that you can define in the Project Settings:
 - `dev_tools_info`          - toggles the info panel on/off
 - `dev_tools_drawing`       - toggles 2D/3D drawing on/off
 - `dev_tools_2d_drawing`    - toggles only 2D drawing on/off
 - `dev_tools_3d_drawing`    - toggles only 3D drawing on/off

Toolbox will use any of the above, if defined.

The default keys are:
 - `backslash` or `tilde` to toggle info panel on/off
 - `ctrl` + `backslash` or `tilde` to toggle drawing on/off (2D and 3D)

###### (I like to use the key next to 1, which in my keyboard is backslash, but in some keyboards it's tilde. The default keys may not work with other keybords.)

### Config File

Toolbox can be customized using a config resource file. You can create a new `ToolboxConfig` resource, and save it at the root of your project as `toolbox_config.tres` or `ToolboxConfig.tres` (or `.res`). I did my best to document the options.


## Toolbox API
	- Toolbox.print_bm(name:String, fn:Callable, options:Dictionary=null)
		- options can contain
			- smoothing:int    - how much to smoothen the reported times
			- precision:int    - the floating point precision for the reported times
			- units:int        - time units: Toolbox.SEC or Toolbox.MSEC

	- Toolbox.benchmark(name:String, num_benchmarks:int, num_iterations:int, fn:Callable)


