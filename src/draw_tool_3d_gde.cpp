
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/variant/utility_functions.hpp>
#include <godot_cpp/core/error_macros.hpp>

#include <godot_cpp/core/math.hpp>
#include <godot_cpp/classes/geometry_instance3d.hpp>
#include <godot_cpp/classes/resource_loader.hpp>
#include <godot_cpp/classes/base_material3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
#include <godot_cpp/classes/multi_mesh_instance3d.hpp>
#include <godot_cpp/classes/box_mesh.hpp>
#include <godot_cpp/classes/cylinder_mesh.hpp>
#include <godot_cpp/classes/sphere_mesh.hpp>
// #include <godot_cpp/classes/config_file.hpp>
// #include <godot_cpp/variant/vector2.hpp>
// #include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/array.hpp>
// #include <godot_cpp/variant/vector3i.hpp>
#include <godot_cpp/variant/color.hpp>
// #include <godot_cpp/variant/string_name.hpp>

#include "draw_tool_3d_gde.h"


void DrawTool3D_GDE::_bind_methods() {
	// ClassDB::bind_method(D_METHOD("test1", "foo"), &DrawTool3D_GDE::test1);
	// ClassDB::bind_method(D_METHOD("test2"), &DrawTool3D_GDE::test2);

	ClassDB::bind_method(D_METHOD("set_width_factor", "width_factor"), &DrawTool3D_GDE::set_width_factor);
	ClassDB::bind_method(D_METHOD("get_width_factor"), &DrawTool3D_GDE::get_width_factor);

	ClassDB::bind_method(D_METHOD("init", "config"), &DrawTool3D_GDE::init);

	// ClassDB::bind_static_method("DrawTool3D_GDE", D_METHOD(
	// 	"_create_arc_points", "position", "axis", "arc_angle", "num_segments", "start_angle"),
	// 	&DrawTool3D_GDE::create_arc_points
	// );

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT,"width_factor", PROPERTY_HINT_NONE), "set_width_factor",   "get_width_factor");
	// ADD_PROPERTY(PropertyInfo(Variant::BOOL, "width_factor", PROPERTY_HINT_NONE), "set_filter_nearest", "get_filter_nearest");

}

DrawTool3D_GDE::DrawTool3D_GDE() {}
DrawTool3D_GDE::~DrawTool3D_GDE() {}

float DrawTool3D_GDE::get_width_factor() {
	return width_factor;
}
void DrawTool3D_GDE::set_width_factor(float n) {
	// return width_factor;
	// CRASH_COND_MSG(true, "width_factor is read only! CRASH!");
	ERR_FAIL_COND_MSG( true, "width_factor is read only! CRASH!" );
}

void DrawTool3D_GDE::_ready() {
	set_name("DrawTool3D");

}

void DrawTool3D_GDE::init(Ref<Resource> config) {
	_init_config(config);

	Node3D* _label_nodes = memnew(Node3D());
	add_child(_label_nodes);
	_label_nodes->set_name("3d_labels");

	_init_im();
	_init_mmis();
}



void DrawTool3D_GDE::_init_config(Ref<Resource> config) {
	// Ref<Resource> data = rl.load("res://addons/gd_dev_toolbox/shared.gd");
	// Ref<Resource> config = data.get_config();

	// if (!config.is_valid()) {
	// 	return;
	// }

	unshaded                      = config->get("unshaded");
	UtilityFunctions::print("config in c++", unshaded);
	on_top                        = config->get("on_top");
	width_factor                  = config->get("width_factor");
	sphere_radial_segments        = config->get("sphere_radial_segments");
	sphere_rings                  = config->get("sphere_rings");
	hollow_sphere_radial_segments = config->get("hollow_sphere_radial_segments");
	hollow_sphere_rings           = config->get("hollow_sphere_rings");
	circle_segments               = config->get("circle_segments");
	cylinder_radial_segments      = config->get("cylinder_radial_segments");
	instance_increment            = config->get("instance_increment");
	cast_shadows                  = config->get("cast_shadows");
	// cast_shadows                  = int(config.cast_shadows);

}


Ref<StandardMaterial3D> DrawTool3D_GDE::_create_material(Color color) {
	Ref<StandardMaterial3D> mat = memnew(StandardMaterial3D());
	mat->set_albedo(color);
	mat->set_flag(BaseMaterial3D::FLAG_ALBEDO_FROM_VERTEX_COLOR, true);
	mat->set_flag(BaseMaterial3D::FLAG_DISABLE_DEPTH_TEST, on_top);
	mat->set_flag(BaseMaterial3D::FLAG_DONT_RECEIVE_SHADOWS, no_shadows);

	if (unshaded) {
		mat->set_shading_mode(BaseMaterial3D::SHADING_MODE_UNSHADED);
	} else {
		mat->set_shading_mode(BaseMaterial3D::SHADING_MODE_PER_PIXEL);
	}

	if (transparent) {
		mat->set_transparency(BaseMaterial3D::TRANSPARENCY_ALPHA);
	} else {
		mat->set_transparency(BaseMaterial3D::TRANSPARENCY_DISABLED);
	}

	return mat;
}


void DrawTool3D_GDE::_init_im() {
	Ref<StandardMaterial3D> _im_base_mat = _create_material(Color(1, 1, 1, face_alpha));
	_im_base_mat->set_cull_mode(double_sided ? BaseMaterial3D::CULL_DISABLED : BaseMaterial3D::CULL_BACK);

	Ref<ImmediateMesh> _im = memnew(ImmediateMesh());
	MeshInstance3D* mi = memnew(MeshInstance3D());
	mi->set_name("Faces_MeshInstance3D");
	mi->set_mesh(_im);
	mi->set_material_override(_im_base_mat);
	add_child(mi);
}


void DrawTool3D_GDE::_init_mmis() {
	Ref<StandardMaterial3D> _base_mat = _create_material( Color(1,1,1,1) );

	_mms["cube_lines"] = _init_line_mesh__cube(_base_mat);

	_mms["cones"]   = _init_cone_mesh(_base_mat);
	// _mms["cubes"]   = _init_cube_mesh(_base_mat);
	// _mms["spheres"] = _init_sphere_mesh(_base_mat);
}


Ref<MultiMesh> DrawTool3D_GDE::_create_multimesh(Ref<Mesh> mesh, String name) {
	Ref<MultiMesh> mm = memnew(MultiMesh());
	mm->set_transform_format(MultiMesh::TRANSFORM_3D);
//	mm->color_format = MultiMesh.COLOR_FLOAT
	mm->set_use_colors(true);
	mm->set_mesh(mesh);
	mm->set_visible_instance_count(0);
	mm->set_instance_count(instance_increment);

	MultiMeshInstance3D* mmi = memnew(MultiMeshInstance3D());
	mmi->set_name(name);
	mmi->set_multimesh(mm);

	// for some reason only the setter function works
	//mmi->set("cast_shadows", 0 as GeometryInstance3D.ShadowCastingSetting)
	//mmi->cast_shadows = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi->set_cast_shadows_setting(GeometryInstance3D::ShadowCastingSetting(cast_shadows));

	add_child(mmi);
	return mm;
}


Ref<MultiMesh> DrawTool3D_GDE::_init_line_mesh__cube(Ref<StandardMaterial3D> mat) {
	Ref<BoxMesh> cube = memnew(BoxMesh());
	cube->set_size(Vector3(width_factor, width_factor, 1));

	cube->set_material(mat);
	return _create_multimesh(cube, "CubeLines_MultiMeshInstance3D");
}


Ref<MultiMesh> DrawTool3D_GDE::_init_cone_mesh(Ref<StandardMaterial3D> mat) {
	// ----------------------------------------
	// create cones (for vectors)

	Ref<CylinderMesh> cone = memnew(CylinderMesh());
	cone->set_top_radius(0);
	cone->set_bottom_radius(width_factor);
	cone->set_height(width_factor*4);
	cone->set_radial_segments(sphere_radial_segments);
	cone->set_rings(0);
	cone->set_material(mat);

	return _create_multimesh(cone, "Cones_MultiMeshInstance3D");
}


Ref<MultiMesh> DrawTool3D_GDE::_init_cube_mesh(Ref<StandardMaterial3D> mat) {
	Ref<BoxMesh> box_mesh = memnew(BoxMesh());
	box_mesh->set_material(mat);
	return _create_multimesh(box_mesh, "Cubes_MultiMeshInstance3D");
}


Ref<MultiMesh> DrawTool3D_GDE::_init_sphere_mesh(Ref<StandardMaterial3D> mat) {
	Ref<SphereMesh> sphere = memnew(SphereMesh());
	sphere->set_radius(0.5);
	sphere->set_height(1);
	sphere->set_radial_segments(sphere_radial_segments);
	sphere->set_rings(sphere_rings);
	sphere->set_material(mat);

	return _create_multimesh(sphere, "Spheres_MultiMeshInstance3D");
}











Array DrawTool3D_GDE::_create_arc_points(Vector3 position, Vector3 axis,
		   float arc_angle, int num_segments, int start_angle)
{
	float radius = axis.length();
	axis = axis.normalized();

	Array points;

	ERR_FAIL_COND_V_EDMSG( axis == Vector3(), points, "axis vector is zero");

	Vector3 _cross_axis = Vector3(0, 1, 0);
	if (axis == _cross_axis) {
		_cross_axis = Vector3(1, 0, 0);
	}

	Vector3 cross = axis.cross(_cross_axis).normalized();
	float dist = arc_angle/float(num_segments);

	for (int i=0; i < num_segments+1; i++) {
		float r = Math::deg_to_rad(start_angle+dist*i);
		Vector3 c = cross.rotated(axis, r);
		Vector3 p = position + c * radius;
		points.append(p);
	}


	return points;
}

