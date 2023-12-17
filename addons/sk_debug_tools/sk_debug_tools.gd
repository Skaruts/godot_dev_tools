@tool
extends EditorPlugin

# Replace this value with a PascalCase autoload name, as per the GDScript style guide.
const AUTOLOAD_NAME = "DebugTools"


func _enter_tree():
	# The autoload can be a scene or script file.
	add_autoload_singleton(AUTOLOAD_NAME, "res://to_plugin/debugger.tscn")


func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
