@tool
extends EditorPlugin


const DT_AUTOLOAD_NAME   := "DevTools"
const DT3D_AUTOLOAD_NAME := "DevTools3D"
const DT2D_AUTOLOAD_NAME := "DevTools2D"


func _enter_tree() -> void:
	# The autoload can be a scene or script file.
	add_autoload_singleton(DT_AUTOLOAD_NAME,   "res://to_plugin/dev_tools.tscn")
	add_autoload_singleton(DT3D_AUTOLOAD_NAME, "res://to_plugin/dev_tools_3d.gd")
	add_autoload_singleton(DT2D_AUTOLOAD_NAME, "res://to_plugin/dev_tools_2d.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(DT_AUTOLOAD_NAME)
	remove_autoload_singleton(DT3D_AUTOLOAD_NAME)
	remove_autoload_singleton(DT2D_AUTOLOAD_NAME)
