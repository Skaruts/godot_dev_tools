extends Node

# shared addon data

const DT_2D_PATH    := "res://addons/sk_dev_tools/tools/draw_tool_2d.gd"
const DT_3D_PATH    := "res://addons/sk_dev_tools/tools/draw_tool_3d.gd"
const SETTINGS_PATH := "res://dev_tools_config.tres"

const DEF_KEYS:Array[int] = [KEY_BACKSLASH, KEY_ASCIITILDE]


static func get_config() -> Variant:
	var valid_paths: Array[String] = [
		"res://dev_tools_config.tres",
		"res://dev_tools_config.res",
		"res://DevToolsConfig.tres",
		"res://DevToolsConfig.res",
	]

	var config:Resource

	for path:String in valid_paths:
		if FileAccess.file_exists(path):
			config = load(path)
			return config as Resource

	return null



static func check_config() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		var dtc := DevToolsConfig.new()
		ResourceSaver.save(dtc, SETTINGS_PATH)
