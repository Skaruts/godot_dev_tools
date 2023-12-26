@tool
extends EditorPlugin


const DT_AUTOLOAD_NAME   := "debug"
const DT2D_AUTOLOAD_NAME := "debug2d"
const DT3D_AUTOLOAD_NAME := "debug3d"


func _enter_tree() -> void:

	# The autoload can be a scene or script file.
	add_autoload_singleton(DT_AUTOLOAD_NAME,   "res://addons/debug_tools/debug.tscn")
	add_autoload_singleton(DT2D_AUTOLOAD_NAME, "res://addons/debug_tools/debug_2d.gd")
	add_autoload_singleton(DT3D_AUTOLOAD_NAME, "res://addons/debug_tools/debug_3d.gd")




func _exit_tree() -> void:
	remove_autoload_singleton(DT_AUTOLOAD_NAME)
	remove_autoload_singleton(DT3D_AUTOLOAD_NAME)
	remove_autoload_singleton(DT2D_AUTOLOAD_NAME)
