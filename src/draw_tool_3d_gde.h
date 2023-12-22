#pragma once

#include <gdextension_interface.h>

#include <godot_cpp/godot.hpp>
#include <godot_cpp/core/defs.hpp>

#include <godot_cpp/classes/node3d.hpp>
#include <godot_cpp/classes/geometry_instance3d.hpp>
#include <godot_cpp/classes/immediate_mesh.hpp>
#include <godot_cpp/classes/standard_material3d.hpp>
#include <godot_cpp/classes/mesh_instance3d.hpp>
#include <godot_cpp/classes/multi_mesh.hpp>
// #include <godot_cpp/classes/control.hpp>
// #include <godot_cpp/classes/config_file.hpp>
// #include <godot_cpp/variant/dictionary.hpp>
// #include <godot_cpp/variant/array.hpp>
// #include <godot_cpp/variant/vector2i.hpp>
// #include <godot_cpp/variant/vector3.hpp>
// #include <godot_cpp/variant/vector3i.hpp>
// #include <godot_cpp/variant/color.hpp>


using namespace godot;

#define _DOT_THRESHOLD 0.999

class DrawTool3D_GDE : public Node3D {
	GDCLASS(DrawTool3D_GDE, Node3D);

private:
	// Ref<ConfigFile> m_config;
	// uint32_t  m_visual_layer_mask      = 1;
	// Ref<Dictionary> m_config;
	Dictionary _mms;    // MultiMeshes
	ImmediateMesh _im;

	bool _use_cylinders_for_lines = false;  // my cylinders code is not working in Godot 4

	Array _labels;  // Array[Label3D]
	Node3D _label_nodes;
	int _num_labels = 0;
	int _num_visible_labels = 0;

	StandardMaterial3D _base_mat;
	StandardMaterial3D _im_base_mat;



public:
	// how thin must the unit-cube be in order to properly represent a line
	// of thickness 1. Lines will look too thick or too thin from too close
	// or too afar, so this must be tweaked according to the intended usage.
	float width_factor = 0.01;

	bool single_color  = false;

	int cast_shadows = GeometryInstance3D::SHADOW_CASTING_SETTING_OFF;


	float line_thickness = 1.0;
	bool unshaded        = true;
	bool on_top          = false;
	bool no_shadows      = true;
	bool transparent     = false;
	bool double_sided    = false;

	float face_alpha     = 0.5;

	int sphere_radial_segments         = 24;
	int sphere_rings                   = 12;
	int hollow_sphere_radial_segments  =  8;
	int hollow_sphere_rings            =  6;
	int circle_segments                = 32;
	int cylinder_radial_segments       =  5;

	// how many instances to add to the MultiMeshInstance when the pool is full
	int instance_increment             = 16;


protected:
	static void _bind_methods();

private:
	Array _create_arc_points(Vector3 position, Vector3 axis,
			   float arc_angle, int num_segments, int start_angle);

	void _create_materials();
	void _init_config(Ref<Resource> config);
	void _init_im();
	void _init_mmis();

	Ref<StandardMaterial3D> _create_material(Color color);
	Ref<MultiMesh> _create_multimesh(Ref<Mesh> mesh, String name);

	Ref<MultiMesh> _init_line_mesh__cube(Ref<StandardMaterial3D> mat);
	Ref<MultiMesh> _init_cone_mesh(Ref<StandardMaterial3D> mat);
	Ref<MultiMesh> _init_cube_mesh(Ref<StandardMaterial3D> mat);
	Ref<MultiMesh> _init_sphere_mesh(Ref<StandardMaterial3D> mat);

public:
	DrawTool3D_GDE();
	~DrawTool3D_GDE();

	void _ready();

	void init(Ref<Resource> config);
	void clear();

	void set_width_factor(float n);
	float get_width_factor();



};
