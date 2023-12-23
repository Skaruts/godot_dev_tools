#class_name DrawTool3D
extends Node3D

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#        DrawTool3D 0.9.9 (Godot 4) by Skaruts  (adapted here for the addon)
#
#
#    - Uses MultiMeshes for lines, cones, spheres, cubes...
#    - Uses an ImmediateMesh to draw faces, since they don't require a thickness.
#    - Uses Label3D for text (may use TextMeshes in the future - need testing).
#
#
#    This draws instances of a cube or cylinder MultiMesh,
#    stretched to represent lines, and instances of spheres for 3D points.
#    For each line AB, it scales an instance of the cube in one axis to equal
#    the distance from A to B, and then rotates it accordingly using
#     'transform.looking_at()'.
#    Cylinders, however, are upright by default, so they have to be
#    manually rotated to compensate for this.
#
#    NOTE: currently, the code I wrote for cylinders in Godot 3 isn't
#    working properly in Godot 4. It's best to keep '_use_cylinders_for_lines'
#    set to false until this is fixed. Using cylinders will result in some
#    lines being oriented wrong.
#
#    NOTE: the 'bulk_*' functions require that the arrays provided to them
#    contain all the arguments that you'd pass to the original drawing
#    functions, including optional arguments.
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#
# TODO:
#   - consider periodically lowering the 'instance_count', since currently it
#     just grows as needed, and stays as is to serve as an object pool,
#     but it never comes back down (not sure it's really an issue)
#
#   - draw quads
#   - draw polygons
#
#   - figure out how to create cylinders through code (and cones), in order
#     to create naturaly a rotated cylinder that will work properly.
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

# 		User settings (change before adding as child)

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
var single_color := false

var cast_shadows := GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

var line_thickness := 1.0
var unshaded       := true    # actually looks great shaded, except for the cylinder caps
var on_top         := false
var no_shadows     := true
var transparent    := false
var double_sided   := false

var face_alpha := 0.5

# how thin must the unit-cube be in order to properly represent a line
# of thickness 1. Lines will look too thick or too thin from too close
# or too afar, so this must be tweaked according to the intended usage.
var width_factor := 0.01

var sphere_radial_segments        := 24
var sphere_rings                  := 12
var hollow_sphere_radial_segments := 8
var hollow_sphere_rings           := 6
var circle_segments               := 32
var cylinder_radial_segments      := 5

# how many instances to add to the MultiMeshInstance when the pool is full
var instance_increment            := 16



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    Public API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Public API
func clear() -> void:
	# keep the real 'instance_count' up, to serve as a pool
	for mm:MultiMesh in _mms.values():
		mm.visible_instance_count = 0
	_clear_labels()
	_im.clear_surfaces()


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#    Drawing API
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
enum {A,B,C,D,E,F,G,H}
func draw_quad(verts:Array[Vector3], color:Color) -> void:
	_im.surface_begin(Mesh.PRIMITIVE_TRIANGLES)#, _im_fore_mat)
	var a := verts[0]
	var b := verts[1]
	var c := verts[2]
	var d := verts[3]

	var tri_verts := [a,b,c,a,c,d]

	for v:Vector3 in tri_verts:
		_im.surface_set_color(color)
		_im.surface_add_vertex(v)

	_im.surface_end()




func draw_line(a:Vector3, b:Vector3, color:Color, thickness:=line_thickness) -> void:
	_add_line(a, b, color, thickness)

# lines = array of arrays: [a, b, color, thickness]
func bulk_lines(lines:Array) -> void:
	for l:Array in lines:
		_add_line(l[0], l[1], l[2], l[3])




# points = contiguous Array[Vector3]
func draw_polyline(points:Array, color:Variant, thickness:=line_thickness) -> void:
	if color is Color:
		for i in range(1, points.size(), 1):
			_add_line(points[i-1], points[i], color, thickness)
	elif color is Array:
		assert(color.size() == points.size())
		for i in range(1, points.size(), 1):
			_add_line(points[i-1], points[i], color[i], thickness)


func bulk_polylines(polylines:Array) -> void:
	for pl:Array in polylines:
		draw_polyline(pl[0], pl[1], pl[2])




#func dashed_line(a:Vector3, b:Vector3, colors:=[], thickness:=line_thickness) -> void:
	#var c1:Color = line_color if colors.size() < 1 else colors[0]
	#var c2:Color = Color.TRANSPARENT if colors.size() < 2 else colors[1]
#
	## TODO: how do I divide the line
	##       the docs for CanvasItem.draw_dashed_line isn't elucidating
#
	#pass

#enum {
	#WIRE         = 1,
	#FACES        = 2,
	#ALL          = 3,
#}




#func cube(p1:Vector3, p2:Vector3, flags:=ALL) -> void:
	#if flags & WIRE:  cube_lines(p1, p2, line_color, line_thickness)
	#if flags & FACES: draw_cube_faces(p1, p2, line_color)




func draw_cube_faces(p1:Vector3, p2:Vector3, color:Color) -> void:
#	var pos := Vector3(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
	var pos := (p1 + p2) / 2
	var size := Vector3(p2.x-p1.x, p2.y-p1.y, p2.z-p1.z).abs()
	_add_cube(pos, size, color)




func draw_point_cube_faces(p:Vector3, size:float, color:Color) -> void:
	_add_cube(p, Vector3(size, size, size), color)

func bulk_point_cube_faces(cubes:Array) -> void:
	for c:Array in cubes:
		var size_v := Vector3(c[1], c[1], c[1])
		_add_cube(c[0], size_v, c[2])




func cube_lines(p1:Vector3, p2:Vector3, color:Color, thickness:=line_thickness, draw_faces:=false) -> void:
	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	var pl1 := [a,b,c,d,a]
	var pl2 := [e,f,g,h,e]

	draw_polyline(pl1, color, thickness)
	draw_polyline(pl2, color, thickness)
	_add_line(a, e, color, thickness)
	_add_line(b, f, color, thickness)
	_add_line(c, g, color, thickness)
	_add_line(d, h, color, thickness)

	if draw_faces:
		draw_cube_faces(p1, p2, color)

func bulk_cube_lines(_cube_lines:Array) -> void:
	for c:Array in _cube_lines:
		# p1, p2, color, thickness, draw_faces
		cube_lines(c[0], c[1], c[2], c[3], c[4])




func draw_aabb(_aabb:AABB, color:Color, thickness:=line_thickness, draw_faces:=false) -> void:
	var p1 := _aabb.position
	var p2 := p1+_aabb.size

	var a := Vector3( p1.x, p2.y, p1.z )
	var b := Vector3( p2.x, p2.y, p1.z )
	var c := Vector3( p2.x, p1.y, p1.z )
	var d := p1
	var e := Vector3( p1.x, p2.y, p2.z )
	var f := p2
	var g := Vector3( p2.x, p1.y, p2.z )
	var h := Vector3( p1.x, p1.y, p2.z )

	var pl1 := [a,b,c,d,a]
	var pl2 := [e,f,g,h,e]

	draw_polyline(pl1, color, thickness)
	draw_polyline(pl2, color, thickness)
	_add_line(a, e, color, thickness)
	_add_line(b, f, color, thickness)
	_add_line(c, g, color, thickness)
	_add_line(d, h, color, thickness)

	if draw_faces:
		draw_cube_faces(p1, p2, color)

func bulk_aabbs(aabbs:Array) -> void:
	for c:Array in aabbs:
		# pos, size, color, thickness, draw_faces
		draw_aabb(c[0], c[1], c[2], c[3])




# useful for drawing vectors as arrows, for example
@warning_ignore("shadowed_variable_base_class")
func draw_cone(position:Vector3, direction:Vector3, color:Color, thickness:=1.0) -> void:
	_add_cone(position, direction, color, thickness)

# cones = array of arrays: [position, direction, color, thickness]
func bulk_cones(cones:Array) -> void:
	for c:Array in cones:
		_add_cone(c[0], c[1], c[2], c[3])




@warning_ignore("shadowed_variable_base_class")
func draw_sphere(position:Vector3, color:Color, size:=1.0, filled:=true, thickness:=1.0) -> void:
	if filled: _add_sphere_filled(position, color, size)
	else:
		Toolbox.benchmark(str(_add_sphere_hollow), 10, 1000, func() -> void:
			_add_sphere_hollow(position, color, size, thickness)
		)


# points = contiguous Array[Vector3]
func batch_pheres(points:Array, colors:Variant, size:=1.0, filled:=true) -> void:
	if colors is Color:
		for p:Vector3 in points:
			draw_sphere(p, colors, size, filled)
	elif colors is Array[Color]:
		for i:int in points.size():
			draw_sphere(points[i], colors[i], size, filled)

# points = array of arrays: [position, color, size]
func bulk_spheres(points:Array) -> void:
	for p:Array in points:
		draw_sphere(p[0], p[1], p[2], p[3])

func bulk_hollow_spheres(points:Array) -> void:
	for p:Array in points:
		draw_sphere(p[0], p[1], p[2], p[3], p[4])




@warning_ignore("shadowed_variable_base_class")
func draw_circle(position:Vector3, normal:Vector3, color:Color, thickness:=1.0, num_segments:=circle_segments) -> void:
	var points := _create_circle_points(position, normal, num_segments)
	draw_polyline(points, color, thickness)

func bulk_circles(circles:Array) -> void:
	for c:Array in circles:
		draw_circle(c[0], c[1], c[2], c[3])




@warning_ignore("shadowed_variable_base_class")
func draw_text(position:Vector3, string:String, color:Color, size:=1.0) -> void:
	_add_label(position, string, color, size)

func bulk_text(labels:Array) -> void:
	for c:Array in labels:
		_add_label(c[0], c[1], c[2], c[3])




#endregion Public API




#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    initialization

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region initialization
const _DOT_THRESHOLD := 0.999

var _mms:Dictionary    # MultiMeshes
var _im:ImmediateMesh

var _use_cylinders_for_lines := false  # my cylinders code is not working in Godot 4

var _labels:Array[Label3D]
var _label_nodes:Node3D
var _num_labels := 0
var _num_visible_labels := 0

var _base_mat:StandardMaterial3D
var _fore_mat:StandardMaterial3D
var _im_base_mat:StandardMaterial3D
var _im_fore_mat:StandardMaterial3D


func _ready() -> void:
	name = "DrawTool3D"

	_init_config()

	_label_nodes = Node3D.new()
	add_child(_label_nodes)
	_label_nodes.name = "3d_labels"

	_init_im()
	_init_mmis()


func _init_config() -> void:
	var data: Resource = load("res://addons/gd_dev_toolbox/shared.gd")
	var config: Resource = data.get_config()
	if not config: return

	unshaded                      = config.unshaded
	on_top                        = config.on_top
	width_factor                  = config.width_factor
	sphere_radial_segments        = config.sphere_radial_segments
	sphere_rings                  = config.sphere_rings
	hollow_sphere_radial_segments = config.hollow_sphere_radial_segments
	hollow_sphere_rings           = config.hollow_sphere_rings
	circle_segments               = config.circle_segments
	cylinder_radial_segments      = config.cylinder_radial_segments
	instance_increment            = config.instance_increment
	cast_shadows                  = int(config.cast_shadows)  as GeometryInstance3D.ShadowCastingSetting

func _init_im() -> void:
	_im_base_mat = _create_material(Color(Color.WHITE, face_alpha))
	_im_base_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK

	_im = ImmediateMesh.new()
	var mi := MeshInstance3D.new()
	mi.name = "Faces_MeshInstance3D"
	mi.mesh = _im
	mi.material_override = _im_base_mat
	add_child(mi)


func _init_mmis() -> void:
	_base_mat = _create_material(Color.WHITE)

#	if _use_cylinders_for_lines:
	_mms["cylinder_lines"] = _init_line_mesh__cylinder(_base_mat)
#	else:
	_mms["cube_lines"] = _init_line_mesh__cube(_base_mat)

	_mms["cones"]   = _init_cone_mesh(_base_mat)
	_mms["cubes"]   = _init_cube_mesh(_base_mat)
	_mms["spheres"] = _init_sphere_mesh(_base_mat)

	# TODO: textmeshes will require some work to support outlines
#	_mms["texts"]   = _init_text_mesh(_base_mat)


func _create_material(color:Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.vertex_color_use_as_albedo = not single_color
	mat.no_depth_test = on_top
	mat.disable_receive_shadows = no_shadows

	if unshaded: mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	else:        mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL

	if transparent: mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:           mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

	return mat


# this is the one used for lines, as cylinders
func _init_line_mesh__cylinder(mat:StandardMaterial3D) -> MultiMesh:
	var cylinder := CylinderMesh.new()
	cylinder.top_radius = width_factor
	cylinder.bottom_radius = width_factor
	cylinder.height = 1
	cylinder.radial_segments = cylinder_radial_segments
	cylinder.rings = 0
	cylinder.cap_top = false
	cylinder.cap_bottom = false

	cylinder.material = mat
	return _create_multimesh(cylinder, "Cylinders_MultiMeshInstance3D")


# this is the one used for lines, as cubes
func _init_line_mesh__cube(mat:StandardMaterial3D) -> MultiMesh:
	var cube := BoxMesh.new()
	cube.size = Vector3(width_factor, width_factor, 1)

	cube.material = mat
	return _create_multimesh(cube, "CubeLines_MultiMeshInstance3D")


func _init_cube_mesh(mat:StandardMaterial3D) -> MultiMesh:
	var box_mesh := BoxMesh.new()
	box_mesh.material = mat
	return _create_multimesh(box_mesh, "Cubes_MultiMeshInstance3D")


#func _init_text_mesh(mat:StandardMaterial3D) -> MultiMesh:
#	var text_mesh := TextMesh.new()
#	text_mesh.material = mat
#
#	return _create_multimesh(text_mesh)


func _init_cone_mesh(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create cones (for vectors)
	@warning_ignore("shadowed_variable")
	var cone := CylinderMesh.new()
	cone.top_radius = 0
	cone.bottom_radius = width_factor
	cone.height = width_factor*4
	cone.radial_segments = sphere_radial_segments
	cone.rings = 0
	cone.material = mat

	return _create_multimesh(cone, "Cones_MultiMeshInstance3D")


func _init_sphere_mesh(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create spheres
	@warning_ignore("shadowed_variable")
	var sphere := SphereMesh.new()
	sphere.radius = 0.5
	sphere.height = 1
	sphere.radial_segments = sphere_radial_segments
	sphere.rings = sphere_rings
	sphere.material = mat

	return _create_multimesh(sphere, "Spheres_MultiMeshInstance3D")


@warning_ignore("shadowed_variable_base_class")
func _create_multimesh(mesh:Mesh, name:String) -> MultiMesh:
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
#	mm.color_format = MultiMesh.COLOR_FLOAT
	mm.use_colors = true
	mm.mesh = mesh
	mm.visible_instance_count = 0
	mm.instance_count = instance_increment

	var mmi := MultiMeshInstance3D.new()
	mmi.name = name
	mmi.multimesh = mm

	# for some reason only the setter function works
	#mmi.set("cast_shadows", 0 as GeometryInstance3D.ShadowCastingSetting)
	#mmi.cast_shadows = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mmi.set_cast_shadows_setting(cast_shadows)

	add_child(mmi)
	return mm

#endregion initialization


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    Internal API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Internal API
@warning_ignore("shadowed_variable_base_class")
func _create_circle_points(position:Vector3, axis:Vector3, num_segments:int, start_angle:=0, connect:=true) -> Array:
	var radius := axis.length()
	axis = axis.normalized()
	assert(axis != Vector3.ZERO)

	# TODO: when the axis used in the cross product below is the same
	# as the circle's axis, use a perpendicular axis instead
	var _cross_axis := Vector3.UP
	if axis == _cross_axis:
		_cross_axis = Vector3.RIGHT
		#if _cross_axis == Vector3.RIGHT:
			#_cross_axis = Vector3.UP
		#elif _cross_axis == Vector3.UP:
			#_cross_axis = Vector3.RIGHT

	var points := []
	var cross := axis.cross(_cross_axis).normalized()

	# this was intended for some edge cases, but it seems like it never happens
	var dot :float = abs(cross.dot(axis))
	if dot > 0.9:
		printerr(_create_circle_points, ": THIS CODE HAS RUN!") # seems like this code never runs
		cross = axis.cross(Vector3.UP) * radius

#	print(axis, cross, dot)

	# draw a debug cross-product vector
	#draw_line(position, position+cross, Color.PURPLE, 2)
	#cone(position+cross, cross, Color.PURPLE, 2)

	var dist := 360.0/float(num_segments)
	for i:int in num_segments+1:
		var r := deg_to_rad(start_angle+dist*i)
		var c := cross.rotated(axis, r)
		var p := position + c * radius
		points.append(p)

	#for r:int in range(start_angle, 360+start_angle, 360/float(num_segments)):
		#var c := cross.rotated(axis, deg_to_rad(r)).normalized()
		#var p := position + c * radius
		#points.append(p)
	#if connect:
		#points.append(points[0])
	return points


func _create_arc_points(position:Vector3, axis:Vector3, arc_angle:float, num_segments:int, start_angle:=0, connect:=false) -> Array:
	var radius := axis.length()
	axis = axis.normalized()
	assert(axis != Vector3.ZERO)

	var _cross_axis := Vector3.UP
	if axis == _cross_axis:
		_cross_axis = Vector3.RIGHT

	var points := []
	var cross := axis.cross(_cross_axis).normalized()# *  radius

	# this was intended for some edge cases, but it seems like it never happens
	var dot :float = abs(cross.dot(axis))
	if dot > 0.9:
		printerr(_create_arc_points, ": THIS CODE HAS RUN!") # seems like this code never runs
		cross = axis.cross(Vector3.UP) * radius

#	print(axis, cross, dot)

	# draw a debug cross-product vector
	#draw_line(position, position+cross, Color.PURPLE, 2)
	#cone(position+cross, cross, Color.PURPLE, 2)
	#arc_angle += 4

	var dist := arc_angle/float(num_segments)
	for i:int in num_segments+1:
		var r := deg_to_rad(start_angle+dist*i)
		var c := cross.rotated(axis, r)
		var p := position + c * radius
		points.append(p)

	#for r:int in range(start_angle, start_angle+arc_angle, arc_angle/float(num_segments)):
		#var c := cross.rotated(axis, deg_to_rad(r))
		#var p := position + c * radius
		#points.append(p)
	#if connect:
		#points.append(points[0])
	return points


@warning_ignore("shadowed_variable_base_class")
func _create_circle_points_OLD(position:Vector3, radius:Vector3, axis:Vector3) -> Array:
	var points := []

	for r:int in range(0, 360, 360/float(sphere_radial_segments)):
		var p := position + radius.rotated(axis, deg_to_rad(r))
		points.append(p)

	return points


# http://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
@warning_ignore("shadowed_variable_base_class")
# 'tr' is actually a an Object method? -- WTF?!?!?
func align_with_y(tr:Transform3D, new_y:Vector3) -> Transform3D:
	if new_y.dot(Vector3.FORWARD) in [-1, 1]:
#		new_y = Vector3.RIGHT
		tr.basis.y = new_y
		tr.basis.z = tr.basis.x.cross(new_y)
		tr.basis = tr.basis.orthonormalized()
	else:
		#printt("dot: ", new_y.dot(Vector3.FORWARD), new_y)

		tr.basis.y = new_y
		tr.basis.x = -tr.basis.z.cross(new_y)
		tr.basis = tr.basis.orthonormalized()
	return tr


#TODO: Test if it's really better to add many instances once in a while
#      versus adding one instance every time it's needed.
#      Maybe there's a tradeoff between too many and too few.
func _add_instance_to(mm:MultiMesh) -> int:
	# the index of a new instance is count-1
	var idx := mm.visible_instance_count

	# if the visible count reaches the instance count, then more instances are needed
	if mm.instance_count <= mm.visible_instance_count+1:
		# this is enough to make the MultiMesh create more instances internally
		mm.instance_count += instance_increment

	mm.visible_instance_count += 1
	return idx


@warning_ignore("shadowed_variable_base_class")
func _commit_instance(mm:MultiMesh, idx:int, transform:Transform3D, color:Color) -> void:
	mm.set_instance_transform(idx, transform)
	# TODO: check what to do about this when using 'single_color'
	mm.set_instance_color(idx, color)



func _add_line(a:Vector3, b:Vector3, color:Color, thickness:=line_thickness) -> void:
	if _use_cylinders_for_lines:
		_add_line_cylinder(a, b, color, thickness)
	else:
		_add_line_cube(a, b, color, thickness)




func _points_are_equal(a:Vector3, b:Vector3) -> bool:
	if a != b: return false
#	push_warning("points 'a' and 'b' are the same: %s == %s" % [a, b])
	return true

func _add_line_cube(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	#Toolbox.benchmark(str(_add_line_cube_), 10, 10000, func() -> void:
		_add_line_cube_(a, b, color, thickness)
	#)

func _add_line_cube_(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	if _points_are_equal(a, b): return

	var mm:MultiMesh = _mms["cube_lines"]

	# adding an instance is basically just raising the visible_intance_count
	# and then using that index to get and set properties of the instance
	var idx := _add_instance_to(mm)

	# if transform is to be orthonormalized, do it here before applying any
	# scaling, or it will revert the scaling
	@warning_ignore("shadowed_variable_base_class")
	#var transform := Transform3D()
	var transform := mm.get_instance_transform(idx).orthonormalized()
	transform.origin = (a+b)/2

	if not transform.origin.is_equal_approx(b):
		var target_direction := a.direction_to(b)
		var dot := absf(target_direction.dot(Vector3.UP))
		transform = transform.looking_at(
			b,
			Vector3.UP if dot < _DOT_THRESHOLD else Vector3.BACK
		)

	# add this, so the lines go slightly over the points and corners look right
	var corner_fix:float = width_factor * thickness

	transform.basis.x *= thickness
	transform.basis.y *= thickness
	transform.basis.z *= a.distance_to(b) + corner_fix

	#transform.basis = transform.basis.scaled(Vector3(
		#thickness,
		#thickness,
		#a.distance_to(b) + corner_fix,
	#))

	_commit_instance(mm, idx, transform, color)



func _add_line_cylinder(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	if _points_are_equal(a, b): return

	var mm:MultiMesh = _mms["cylinder_lines"]
	var idx := _add_instance_to(mm)

	@warning_ignore("shadowed_variable_base_class")
	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
	transform.origin = (a+b)/2

	#var target_direction := (b-transform.origin).normalized()
	var target_direction := a.direction_to(b)
	if not transform.origin.is_equal_approx(b):
		transform = align_with_y(transform, target_direction)

	#	printt("target_direction", target_direction, b)
#	transform = transform.looking_at(b,
#		Vector3.BACK if abs(target_direction.dot(Vector3.FORWARD)) < _DOT_THRESHOLD
#		else Vector3.UP
#	)

	#	var dot = abs(target_direction.dot(axis))
	#	if dot > 0.9:
	#		print("I WAS HERE") # this seems to never run
	#		cross = axis.cross(Vector3.UP) * radius


	transform.basis.x *= thickness
	transform.basis.y *= a.distance_to(b) # + width_factor * thickness # stretch the Y instead
	transform.basis.z *= thickness

	_commit_instance(mm, idx, transform, color)


@warning_ignore("shadowed_variable_base_class", "unused_parameter")
func _add_cone(position:Vector3, direction:Vector3, color:Color, thickness:=1.0) -> void:
	var mm:MultiMesh = _mms["cones"]

	var idx := _add_instance_to(mm)
	var transform := Transform3D()
	transform.origin = position

	transform = align_with_y(transform, direction)
	#transform.basis = transform.basis.scaled(direction)
	transform.basis = transform.basis.scaled(Vector3.ONE * thickness)
	#transform.basis = transform.basis.scaled(Vector3(1, 3, 1))
	#transform.basis = transform.basis.scaled((Vector3(thickness, length, thickness)).direction_to(position+direction))


	_commit_instance(mm, idx, transform, color)


@warning_ignore("shadowed_variable_base_class")
func _add_sphere_filled(position:Vector3, color:Color, size:=1.0) -> void:
	var mm:MultiMesh = _mms["spheres"]

	var idx := _add_instance_to(mm)
#	var transform := mm.get_instance_transform(idx).orthonormalized()
	var transform := Transform3D()

	transform.origin = position
	transform.basis = transform.basis.scaled(Vector3.ONE * size)

	_commit_instance(mm, idx, transform, color)


func _add_sphere_hollow(position:Vector3, color:Color, diameter:=1.0, thickness:=1.0) -> void:
	var radius := diameter/2.0
	var meridian_points := _create_circle_points(position, Vector3.RIGHT*radius, hollow_sphere_rings*2, 90)
	meridian_points.resize(meridian_points.size()/2.0)   # only interested in half of the circle here

	var a:Vector3 = meridian_points[1] # don't use 0, as it is the same as 'position' in x and z
	var start_direction := Vector3(position.x, a.y, position.z).direction_to(a)

	var p1 := position - Vector3.UP*radius

	#var polylines := []

	var dist := (diameter)/float(hollow_sphere_rings)
	for i in range(1, meridian_points.size()):
		var mp:Vector3 = meridian_points[i]
		var r:float = absf(mp.z-p1.z)
		var p := Vector3(p1.x, mp.y, p1.z)
		var points := _create_arc_points(p, Vector3.UP*r, 360, hollow_sphere_radial_segments, 90)
		draw_polyline(points, color, thickness)
		#polylines.append([points, color, thickness])


	for i in hollow_sphere_radial_segments:
		var angle := 360/hollow_sphere_radial_segments
		var direction := start_direction.rotated(Vector3.UP, deg_to_rad(i * angle) )
		var points := _create_arc_points(position, direction*radius, 180, hollow_sphere_rings, 90, false)
		draw_polyline(points, color, thickness)
		#polylines.append([points, color, thickness])

	#bulk_polylines(polylines)



@warning_ignore("shadowed_variable_base_class")
func _add_cube(position:Vector3, size:Vector3, color:Color) -> void:
	var mm:MultiMesh = _mms["cubes"]
	var idx := _add_instance_to(mm)

	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
	transform.origin = position
	transform.basis.x *= size
	transform.basis.y *= size
	transform.basis.z *= size

	_commit_instance(mm, idx, transform, color)


func _create_new_label(fixed_size:=false) -> Label3D:
	var l := Label3D.new()
	_label_nodes.add_child(l)
	_labels.append(l)
	_num_labels += 1

	l.fixed_size    = fixed_size
	l.shaded        = not unshaded
	l.double_sided  = double_sided
	l.no_depth_test = on_top
	l.billboard     = BaseMaterial3D.BILLBOARD_ENABLED
	return l


func _clear_labels() -> void:
	for l:Label3D in _labels:
		l.visible = false
	_num_visible_labels = 0

# using a similar system to the MultiMeshInstance
@warning_ignore("shadowed_variable_base_class")
func _add_label(position:Vector3, string:String, color:Color, size:=1.0, fixed_size:=false) -> void:
	var l:Label3D
	_num_visible_labels += 1

	if _num_labels < _num_visible_labels:
		l = _create_new_label(fixed_size)
	else:
		l = _labels[_num_visible_labels-1]
		l.visible = true

	l.position = position
	l.text     = string
	l.modulate = color
	l.scale    = Vector3.ONE * size


#endregion    Internal API

