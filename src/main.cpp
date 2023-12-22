#include <gdextension_interface.h>

#include <godot_cpp/godot.hpp>
#include <godot_cpp/core/class_db.hpp>

#include <draw_tool_3d_gde.h>

using namespace godot;

void register_draw_tool_3d_types(ModuleInitializationLevel p_level)
{
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	ClassDB::register_class<DrawTool3D_GDE>();
}

void unregister_draw_tool_3d_types(ModuleInitializationLevel p_level)
{
}

extern "C"
{
	GDExtensionBool GDE_EXPORT draw_tool_3d_init(
			GDExtensionInterfaceGetProcAddress p_get_proc_address,
			GDExtensionClassLibraryPtr p_library,
			GDExtensionInitialization *r_initialization)
	{
		GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

		init_obj.register_initializer(register_draw_tool_3d_types);
		init_obj.register_terminator(unregister_draw_tool_3d_types);

		return init_obj.init();
	}
}
