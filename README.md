# godot_dev_tools
This addon provides a few handy tools for general development and debugging.

## Usage:

There are three autoloads added by this addon:

- `DevTools`    - for text information and quick benchmarking
- `DevTools2D`  - for 2D shape drawing
- `DevTools3D`  - for 3D shape drawing

You can use them to display information in the way you find most suitable.

#### Input Actions

By default, DevTools uses hardcoded key bindings, but it supports some input actions that you can define in the Project Settings:
- dev_tools_info       (toggles the info panel on/off)
- dev_tools_drawing    (toggles 2D/3D drawing on/off)

DevTools will use any of the above, if defined.

### Customizing DevTools - Config File

DevTools can be customized using a config resource file. Create a new DevToolsConfig resource, and save it at the root of your project as dev_tools_config.tres




### DevTools API
	DevTools.bm(name:String, f:Callable, smoothing:int=default, precision:float=default, time_units:float=default)

