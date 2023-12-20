extends Node

# shared addon data

const DT_2D_PATH    := "res://addons/gd_dev_toolbox/tools/draw_tool_2d.gd"
const DT_3D_PATH    := "res://addons/gd_dev_toolbox/tools/draw_tool_3d.gd"

const DEF_KEYS:Array[int] = [KEY_BACKSLASH, KEY_ASCIITILDE]

const _VALID_SETTINGS_PATHS: Array[String] = [
	"res://toolbox_config.tres",
	"res://toolbox_config.res",
	"res://ToolboxConfig.tres",
	"res://ToolboxConfig.res",
]

static func get_config() -> Variant:
	var config:Resource

	for path:String in _VALID_SETTINGS_PATHS:
		if FileAccess.file_exists(path):
			config = load(path)
			return config as Resource

	return null



#static func validate_or_create_config() -> void:
	#for path:String in _VALID_SETTINGS_PATHS:
		#if FileAccess.file_exists(path):
			#return
#
	#var config_res := ToolboxConfig.new()
	#ResourceSaver.save(config_res, _VALID_SETTINGS_PATHS[0])
