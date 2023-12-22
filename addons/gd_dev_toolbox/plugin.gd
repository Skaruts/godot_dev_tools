@tool
extends EditorPlugin


const DT_AUTOLOAD_NAME   := "Toolbox"
const DT3D_AUTOLOAD_NAME := "Toolbox3D"
const DT2D_AUTOLOAD_NAME := "Toolbox2D"


func _enter_tree() -> void:


	# The autoload can be a scene or script file.
	add_autoload_singleton(DT_AUTOLOAD_NAME,   "res://addons/gd_dev_toolbox/toolbox.tscn")
	add_autoload_singleton(DT2D_AUTOLOAD_NAME, "res://addons/gd_dev_toolbox/toolbox_2d.gd")
	add_autoload_singleton(DT3D_AUTOLOAD_NAME, "res://addons/gd_dev_toolbox/toolbox_3d.gd")

	#var tb := ToolboxAPI.new()
	#tb.test2()


func _exit_tree() -> void:
	remove_autoload_singleton(DT_AUTOLOAD_NAME)
	remove_autoload_singleton(DT3D_AUTOLOAD_NAME)
	remove_autoload_singleton(DT2D_AUTOLOAD_NAME)
