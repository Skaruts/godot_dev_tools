
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
#include <godot_cpp/classes/label3d.hpp>
// #include <godot_cpp/classes/config_file.hpp>
// #include <godot_cpp/variant/vector2.hpp>
// #include <godot_cpp/variant/vector2i.hpp>
#include <godot_cpp/variant/vector3.hpp>
#include <godot_cpp/variant/array.hpp>
// #include <godot_cpp/variant/vector3i.hpp>
#include <godot_cpp/variant/color.hpp>
// #include <godot_cpp/variant/string_name.hpp>

#include "draw_tool_3d_gde.h"

#define _DOT_THRESHOLD 0.999
#define VECTOR3_UP Vector3(0,1,0)
#define VECTOR3_FORWARD Vector3(0,0,-1)
#define VECTOR3_BACK Vector3(0,0,1)
#define VECTOR3_RIGHT Vector3(1,0,0)
#define VECTOR3_ONE Vector3(1,1,1)


void DrawTool3D_GDE::_bind_methods() {
	// ClassDB::bind_method(D_METHOD("set_width_factor", "width_factor"), &DrawTool3D_GDE::set_width_factor);
	// ClassDB::bind_method(D_METHOD("get_width_factor"), &DrawTool3D_GDE::get_width_factor);

	ClassDB::bind_method(D_METHOD("init", "config"), &DrawTool3D_GDE::init);
	ClassDB::bind_method(D_METHOD("clear"), &DrawTool3D_GDE::clear);

	ClassDB::bind_method(D_METHOD("draw_line", "a", "b", "color", "thickness"), &DrawTool3D_GDE::draw_line);
	ClassDB::bind_method(D_METHOD("bulk_lines", "lines"), &DrawTool3D_GDE::bulk_lines);

	ClassDB::bind_method(D_METHOD("draw_polyline", "points", "color", "thickness"), &DrawTool3D_GDE::draw_polyline);
	ClassDB::bind_method(D_METHOD("bulk_polylines", "polylines"), &DrawTool3D_GDE::bulk_polylines);


	ClassDB::bind_method(D_METHOD("draw_sphere", "position", "color", "size", "filled", "thickness"), &DrawTool3D_GDE::draw_sphere);
	ClassDB::bind_method(D_METHOD("batch_pheres", "points", "color", "size", "filled", "thickness"), &DrawTool3D_GDE::batch_pheres);
	ClassDB::bind_method(D_METHOD("bulk_spheres", "points"), &DrawTool3D_GDE::bulk_spheres);
	ClassDB::bind_method(D_METHOD("bulk_hollow_spheres", "points"), &DrawTool3D_GDE::bulk_hollow_spheres);

	ClassDB::bind_method(D_METHOD("draw_cone", "position", "direction", "color", "thickness"), &DrawTool3D_GDE::draw_cone);
	ClassDB::bind_method(D_METHOD("bulk_cones", "cones"), &DrawTool3D_GDE::bulk_cones);

	// ClassDB::bind_static_method("DrawTool3D_GDE", D_METHOD(
	// 	"_create_arc_points", "position", "axis", "arc_angle", "num_segments", "start_angle"),
	// 	&DrawTool3D_GDE::create_arc_points
	// );

	// ADD_PROPERTY(PropertyInfo(Variant::FLOAT,"width_factor", PROPERTY_HINT_NONE), "set_width_factor",   "get_width_factor");
	// ADD_PROPERTY(PropertyInfo(Variant::BOOL, "width_factor", PROPERTY_HINT_NONE), "set_filter_nearest", "get_filter_nearest");

}

DrawTool3D_GDE::DrawTool3D_GDE() {}
DrawTool3D_GDE::~DrawTool3D_GDE() {}


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

void DrawTool3D_GDE::clear() {
	// keep the real 'instance_count' up, to serve as a pool
	Array values = _mms.values();
	for (int i = 0; i < values.size(); i++) {
		Ref<MultiMesh> mm = values[i];
		mm->set_visible_instance_count(0);
	}
	_clear_labels();

	_im->clear_surfaces();
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

	// _im = memnew(ImmediateMesh());
	_im.instantiate();
	// _im = Object::cast_to<ImmediateMesh>(memnew(ImmediateMesh()));

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
	_mms["cubes"]   = _init_cube_mesh(_base_mat);
	_mms["spheres"] = _init_sphere_mesh(_base_mat);
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

	Vector3 _cross_axis = VECTOR3_UP;
	if (axis == _cross_axis) {
		_cross_axis = VECTOR3_RIGHT;
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


// http://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
Transform3D DrawTool3D_GDE::_align_with_y(Transform3D tr, Vector3 new_y) {
	float dot = new_y.dot(VECTOR3_FORWARD);

	if (dot == -1 || dot == 1) {
		tr.basis.get_column(1) = new_y;
		tr.basis.get_column(2) = tr.basis.get_column(0).cross(new_y);
		tr.basis = tr.basis.orthonormalized();
	} else {
		tr.basis.get_column(1) = new_y;
		tr.basis.get_column(0) = -tr.basis.get_column(2).cross(new_y);
		tr.basis = tr.basis.orthonormalized();
	}
	return tr;
}


bool DrawTool3D_GDE::_points_are_equal(Vector3 a, Vector3 b) {
	if (a != b) {
		return false;
	}
	//	push_warning("points 'a' and 'b' are the same: %s == %s" % [a, b])
	return true;
}

int DrawTool3D_GDE::_add_instance_to(Ref<MultiMesh> mm) {
	int visible_count = mm->get_visible_instance_count();
	int instance_count = mm->get_instance_count();
	// the index of a new instance is count-1
	int idx = visible_count;

	// if the visible count reaches the instance count, then more instances are needed
	if (instance_count <= visible_count+1) {
		// this is enough to make the MultiMesh create more instances internally
		mm->set_instance_count(visible_count + instance_increment);
	}
	mm->set_visible_instance_count(visible_count+1);

	return idx;
}


void DrawTool3D_GDE::_commit_instance(Ref<MultiMesh> mm, int idx, Transform3D transform, Color color) {
	mm->set_instance_transform(idx, transform);
	mm->set_instance_color(idx, color);
}


void DrawTool3D_GDE::_add_line(Vector3 a, Vector3 b, Color color, float thickness) {
	// if (_use_cylinders_for_lines) {
	// 	_add_line_cylinder(a, b, color, thickness);
	// } else {
		_add_line_cube(a, b, color, thickness);
	// }
}

void DrawTool3D_GDE::_add_line_cube(Vector3 a, Vector3 b, Color color, float thickness) {
	if (_points_are_equal(a, b)) { return; }

	Ref<MultiMesh> mm = _mms["cube_lines"];

	int idx = _add_instance_to(mm);

	// Ref<Transform3D> transform = memnew(Transform3D());
	// Transform3D transform = Transform3D();
	Transform3D transform = mm->get_instance_transform(idx).orthonormalized();
	transform.origin = (a + b) / 2;

	if (!transform.origin.is_equal_approx(b)) {
		// TODO: maybe I could just do 'if target_direction.is_equal_approx(Vector3.UP)'
		// and ditch the dot product and the _DOT_THRESHOLD
		// all this needs is to know is if direction is near Vector3.UP,
		// and if so, then use Vector3.BACK as the up vector
		Vector3 target_direction = a.direction_to(b);
		float dot = Math::absf(target_direction.dot(VECTOR3_UP));
		transform = transform.looking_at(b, dot < _DOT_THRESHOLD ? VECTOR3_UP : VECTOR3_BACK);
	}

	// add this, so the lines go slightly over the points and corners look right
	float corner_fix = (width_factor * thickness);

	Vector3 sc = Vector3(
		thickness,
		thickness,
		a.distance_to(b) + corner_fix
	);
	// transform.basis = transform.basis.scaled(sc);
	// transform = transform.scaled(sc);
	transform = transform.scaled_local(sc);

	// transform.basis = transform.basis.transposed();
	// UtilityFunctions::printt(transform);
	// UtilityFunctions::printt(transform.basis[0]);
	// transform.basis[0] *= thickness;
	// transform.basis[1] *= thickness;
	// transform.basis[2] *= a.distance_to(b) + corner_fix;

	// UtilityFunctions::printt(transform);

	_commit_instance(mm, idx, transform, color);
}

void DrawTool3D_GDE::_add_cone(Vector3 position, Vector3 direction, Color color, float thickness) {
	Ref<MultiMesh> mm = _mms["cones"];

	int idx = _add_instance_to(mm);

	Transform3D transform = mm->get_instance_transform(idx).orthonormalized();
	transform.origin = position;

	Vector3 b = position+direction;

	if (!transform.origin.is_equal_approx(b)) {
		Vector3 target_direction = position.direction_to(b);
		float dot = Math::absf(target_direction.dot(VECTOR3_UP));
		transform = transform.looking_at(b, dot < _DOT_THRESHOLD ? VECTOR3_UP : VECTOR3_BACK);
	}

	transform = transform.rotated_local(VECTOR3_RIGHT, Math::deg_to_rad(-90.0));
	transform = transform.scaled_local(VECTOR3_ONE * thickness);

	_commit_instance(mm, idx, transform, color);
}

void DrawTool3D_GDE::_add_sphere_filled(Vector3 position, Color color, float size) {
	Ref<MultiMesh> mm = _mms["spheres"];

	int idx = _add_instance_to(mm);
	// Transform3D* transform = mm->get_instance_transform(idx).orthonormalized()
	// Transform3D* transform = memnew(Transform3D());
	Transform3D transform = mm->get_instance_transform(idx).orthonormalized();

	transform.origin = position;
	transform.basis = transform.basis.scaled(VECTOR3_ONE * size);

	_commit_instance(mm, idx, transform, color);
}


// TODO: shouldn't this take a radius instead of a diameter?
void DrawTool3D_GDE::_add_sphere_hollow(Vector3 position, Color color, float diameter, float thickness) {
	float radius = diameter/2.0;
	Array meridian_points = _create_arc_points(position, VECTOR3_RIGHT*radius, 360, hollow_sphere_rings*2, 90);
	meridian_points.resize(meridian_points.size()/2);   // only interested in half of the circle here

	Vector3 tmp_pt = meridian_points[1]; // don't use 0, as it is the same as 'position' in x and z
	Vector3 start_direction = Vector3(position.x, tmp_pt.y, position.z).direction_to(tmp_pt);

	Vector3 p1 = position - VECTOR3_UP * radius;

	float dist = diameter/float(hollow_sphere_rings);
	for (int i = 1; i < meridian_points.size(); i++) {
		Vector3 mp = meridian_points[i];
		float r = Math::absf(mp.z-p1.z);
		Vector3 p = Vector3(p1.x, mp.y, p1.z);
		Array points = _create_arc_points(p, VECTOR3_UP*r, 360, hollow_sphere_radial_segments, 90);
		draw_polyline(points, color, thickness);
	}

	for (int i = 0; i < hollow_sphere_radial_segments; i++) {
		float angle = 360/hollow_sphere_radial_segments;
		Vector3 direction = start_direction.rotated(VECTOR3_UP, Math::deg_to_rad(i * angle) );
		Array points = _create_arc_points(position, direction*radius, 180, hollow_sphere_rings, 90);
		draw_polyline(points, color, thickness);
	}
}


void DrawTool3D_GDE::_add_cube(Vector3 position, Vector3 size, Color color) {
	Ref<MultiMesh> mm = _mms["cubes"];
	int idx = _add_instance_to(mm);
	Transform3D transform = mm->get_instance_transform(idx).orthonormalized();

	transform.origin = position;
	transform.basis[0] *= size;
	transform.basis[1] *= size;
	transform.basis[2] *= size;

	_commit_instance(mm, idx, transform, color);
}


Label3D* DrawTool3D_GDE::_create_new_label(bool fixed_size) {
	Label3D* l = memnew(Label3D());
	_label_nodes.add_child(l);
	_labels.append(l);
	_num_labels += 1;

	l->set_draw_flag(Label3D::FLAG_SHADED, !unshaded);
	l->set_draw_flag(Label3D::FLAG_DOUBLE_SIDED, double_sided);
	l->set_draw_flag(Label3D::FLAG_DISABLE_DEPTH_TEST, on_top);
	l->set_draw_flag(Label3D::FLAG_FIXED_SIZE, fixed_size);
	l->set_billboard_mode(BaseMaterial3D::BILLBOARD_ENABLED);

	return l;
}


void DrawTool3D_GDE::_clear_labels() {
	for (int i = 0; i < _labels.size(); i++) {
		Label3D* l = Object::cast_to<Label3D>(_labels[i]);
		l->set_visible(false);
	}
	_num_visible_labels = 0;
}

// using a similar system to the MultiMeshInstance
void DrawTool3D_GDE::_add_label(Vector3 position, String string, Color color, float size, bool fixed_size) {
	Label3D* l;
	_num_visible_labels += 1;

	if (_num_labels < _num_visible_labels) {
		l = _create_new_label(fixed_size);
	} else {
		l = Object::cast_to<Label3D>(_labels[_num_visible_labels-1]);
		l->set_visible(true);
	}
	l->set_position(position);
	l->set_text(string);
	l->set_modulate(color);
	l->set_scale(VECTOR3_ONE * size);
}




/*******************************************************************************
*
*			PUBLIC API
*
*******************************************************************************/
void DrawTool3D_GDE::draw_line(Vector3 a, Vector3 b, Color color, float thickness) {
	_add_line(a, b, color, thickness);
}

// lines = array of arrays: [a, b, color, thickness]
void DrawTool3D_GDE::bulk_lines(Array lines) {
	for (int i = 0; i < lines.size(); i++) {
		Array l = lines[i];
		// Array* l = Object::cast_to<Array>(lines[i]);
		_add_line(l[0], l[1], l[2], l[3]);
	}
}


// void DrawTool3D_GDE::test1(int i) {
// 	UtilityFunctions::print("this is an int: ", i);
// }
// void DrawTool3D_GDE::test1(String foo) {
// 	UtilityFunctions::print("this is a string: ", foo);
// }


// points = contiguous Array[Vector3]
void DrawTool3D_GDE::draw_polyline(Array points, Variant color, float thickness) {
	switch (color.get_type()) {
		case Variant::COLOR: {
			for (int i = 1; i < points.size(); i++) {
				Vector3 p2 = points[i];
				Vector3 p1 = points[i-1];
				_add_line(p1, p2, color, thickness);
			}
			break;
		}
		case Variant::ARRAY: {
			Array colors = color;
			ERR_FAIL_COND_MSG(colors.size() != points.size(), "points and colors in different quantities");

			for (int i = 1; i < points.size(); i++) {
				Vector3 p2 = points[i];
				Vector3 p1 = points[i-1];
				Color c = colors[i];
				_add_line(p1, p2, c, thickness);
			}
			break;
		}
	}
}

void DrawTool3D_GDE::bulk_polylines(Array polylines) {
	// for pl:Array in polylines:
	// 	draw_polyline(pl[0], pl[1], pl[2])

	for (int i = 0; i < polylines.size(); i++) {
		Array pl = polylines[i];
		draw_polyline(pl[0], pl[1], pl[2]);
	}
}



void DrawTool3D_GDE::draw_cone(Vector3 position, Vector3 direction, Color color, float thickness) {
	_add_cone(position, direction, color, thickness);
}

// cones = array of arrays: [position, direction, color, thickness]
void DrawTool3D_GDE::bulk_cones(Array cones) {
	for (int i = 0; i < cones.size(); i++) {
		Array c = cones[i];
		_add_cone(c[0], c[1], c[2], c[3]);
	}
}



void DrawTool3D_GDE::draw_sphere(Vector3 position, Color color, float size, bool filled, float thickness) {
	// if (filled)
	// 	_add_sphere_filled(position, color, size)
	// else:
	_add_sphere_hollow(position, color, size, thickness);
}

// points = contiguous Array[Vector3]
void DrawTool3D_GDE::batch_pheres(Array points, Variant color, float size, bool filled, float thickness) {
	switch (color.get_type()) {
		case Variant::COLOR: {
			for (int i = 0; i < points.size(); i++) {
				Vector3 p = points[i];
				draw_sphere(p, color, size, filled, thickness);
			}
		}
		case Variant::ARRAY: {
			Array colors = color;
			for (int i = 0; i < points.size(); i++) {
				Vector3 p = points[i];
				Color c = colors[i];
				draw_sphere(p, c, size, filled, thickness);
			}
		}
	}
}

// points = array of arrays: [position, color, size]
void DrawTool3D_GDE::bulk_spheres(Array points) {
	for (int i = 0; i < points.size(); i++) {
		Array p = points[i];
		draw_sphere(p[0], p[1], p[2], p[3], p[4]);
	}
}

void DrawTool3D_GDE::bulk_hollow_spheres(Array points) {
	for (int i = 0; i < points.size(); i++) {
		Array p = points[i];
		draw_sphere(p[0], p[1], p[2], p[3], p[4]);
	}
}

