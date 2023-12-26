extends Node

# shared addon data

const DT_2D_PATH    := "res://addons/debug_tools/tools/drawing_2d.gd"
const DT_3D_PATH    := "res://addons/debug_tools/tools/drawing_3d.gd"

const DEF_KEYS:Array[int] = [KEY_BACKSLASH, KEY_ASCIITILDE]

const INPUT_ACTION_MONITORING := "debug_tools_monitoring"
const INPUT_ACTION_DRAWING := "debug_tools_drawing"
const INPUT_ACTION_2D_DRAWING := "debug_tools_2d_drawing"
const INPUT_ACTION_3D_DRAWING := "debug_tools_3d_drawing"

const _VALID_CONFIG_PATHS: Array[String] = [
	"res://debug_tools_config.tres",
	"res://debug_tools_config.res",
	"res://DebugToolsConfig.tres",
	"res://DebugToolsConfig.res",
]

static func get_config() -> Variant:
	var config:Resource

	for path:String in _VALID_CONFIG_PATHS:
		if FileAccess.file_exists(path):
			config = load(path)
			return config as Resource

	return null



#static func validate_or_create_config() -> void:
	#for path:String in _VALID_CONFIG_PATHS:
		#if FileAccess.file_exists(path):
			#return
#
	#var config_res := debugConfig.new()
	#ResourceSaver.save(config_res, _VALID_CONFIG_PATHS[0])
