#class_name DrawTool3D
extends Node3D

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#        DrawTool3D 0.9.9 (Godot 4) by Skaruts
#
#    (Slightly adapted here for the DebugTools plugin)
#
#    - Uses MultiMeshes for lines, cones, spheres, cubes...
#    - Uses an ImmediateMesh to draw faces, since they don't require a thickness.
#    - Uses Label3D for text (may use TextMeshes in the future - need testing).
#
#
#    This uses MultiMeshInstances to draw instances of a cube or cylinder MultiMesh,
#    stretched to represent lines, and instances of spheres for 3D points.
#    For each line AB, scales an instance of a cube in one axis to equal the
#    distance from A to B, and then rotates it accordingly using
#     'transform.looking_at()'.
#    Cylinders, however, are upright by default, so they have to be
#    manually rotated to compensate for this.
#
#    NOTE: currently, the code I wrote for cylinders in Godot 3 isn't
#    working properly in Godot 4. It's best to keep '_use_cylinders_for_lines'
#    set to false until this is fixed.
#
#    NOTE: bulk_* functions require that the arrays that are provided to them
#    contain all the arguments, including optional argumetns, that you'd pass
#    to the original drawing function. They are intended for usage in tools,
#    rather than directly by users (the batch_* functions are intended for users).
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#
# TODO:
#   - consider periodically lowering the 'instance_count', since currently it
#     grows as needed, and stays as is to serve as an object pool,
#     but it never comes back down (not sure it's really an issue)
#
#   - draw quads
#   - draw polygons
#
#   - create cylinders without caps through code (and cones) ?
#
#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

# 		User settings (change before adding as child)

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
var single_color := false

var line_color := Color.WHITE
var backline_color:Color
var face_color:Color
var backface_color:Color

var line_thickness := 1.0
var unshaded := true    # actually looks great shaded, except for the cylinder caps
var on_top := false
var no_shadows := true
#var render_priority := 0
var transparent := false
var double_sided := false

var back_alpha := 0.5
var face_alpha := 0.5
var darken_factor := 0.25
var see_through := false  # TODO: this doesn't seem to work reliably

# how thin must the unit-cube be in order to properly represent a line
# of thickness 1. Lines will look too thick or too thin from too close
# or too afar, so this must be tweaked according to the intended usage.
var width_factor := 0.01

var sphere_radial_segments := 24
var sphere_rings    := 12
var circle_segments := 32
var cylinder_radial_segments := 5

# how many instances to add when more instances are needed
var instance_increment := 16



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
func quad(verts:Array[Vector3], color:=face_color) -> void:
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




func line(a:Vector3, b:Vector3, color:=line_color, thickness:=line_thickness) -> void:
	_add_line(a, b, color, thickness)

# lines = array of arrays: [a, b, color, thickness]
func bulk_lines(lines:Array) -> void:
	for l:Array in lines:
		_add_line(l[0], l[1], l[2], l[3])




# points = contiguous Array[Vector3]
func polyline(points:Array, color:=line_color, thickness:=line_thickness) -> void:
	for i in range(1, points.size(), 1):
		_add_line(points[i-1], points[i], color, thickness)

func bulk_polylines(polylines:Array) -> void:
	for pl:Array in polylines:
		polyline(pl[0], pl[1], pl[2])




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
	#if flags & FACES: cube_faces(p1, p2, line_color)




func cube_faces(p1:Vector3, p2:Vector3, color:=line_color) -> void:
#	var pos := Vector3(min(p1.x, p2.x), min(p1.y, p2.y), min(p1.z, p2.z))
	var pos := (p1 + p2) / 2
	var size := Vector3(p2.x-p1.x, p2.y-p1.y, p2.z-p1.z).abs()
	_add_cube(pos, size, color)




func point_cube_faces(p:Vector3, size:=1.0, color:=line_color) -> void:
	_add_cube(p, Vector3(size, size, size), color)

func bulk_point_cube_faces(cubes:Array) -> void:
	for c:Array in cubes:
		var size_v := Vector3(c[1], c[1], c[1])
		_add_cube(c[0], size_v, c[2])




func cube_lines(p1:Vector3, p2:Vector3, color:=line_color, thickness:=line_thickness, draw_faces:=false) -> void:
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

	polyline(pl1, color, thickness)
	polyline(pl2, color, thickness)
	_add_line(a, e, color, thickness)
	_add_line(b, f, color, thickness)
	_add_line(c, g, color, thickness)
	_add_line(d, h, color, thickness)

	if draw_faces:
		cube_faces(p1, p2, color)

func bulk_cube_lines(cube_lines:Array) -> void:
	for c:Array in cube_lines:
		# p1, p2, color, thickness, draw_faces
		cube_lines(c[0], c[1], c[2], c[3], c[4])




func aabb(aabb:AABB, color:=line_color, thickness:=line_thickness, draw_faces:=false) -> void:
	var p1 := aabb.position
	var p2 := p1+aabb.size

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

	polyline(pl1, color, thickness)
	polyline(pl2, color, thickness)
	_add_line(a, e, color, thickness)
	_add_line(b, f, color, thickness)
	_add_line(c, g, color, thickness)
	_add_line(d, h, color, thickness)

	if draw_faces:
		cube_faces(p1, p2, color)

func bulk_aabbs(aabbs:Array) -> void:
	for c:Array in aabbs:
		# pos, size, color, thickness, draw_faces
		aabb(c[0], c[1], c[2], c[3])




# useful for drawing vectors as arrows, for example
func cone(position:Vector3, direction:Vector3, color:Color, length:=3.0, thickness:=1.0) -> void:
	_add_cone(position, direction, color, length, thickness)

# cones = array of arrays: [position, direction, color, thickness]
func bulk_cones(cones:Array) -> void:
	for c:Array in cones:
		_add_cone(c[0], c[1], c[2], c[3], c[4])




func sphere(position:Vector3, color:Color, size:=1.0) -> void:
	_add_sphere(position, color, size)

# points = contiguous Array[Vector3]
func batch_pheres(points:Array, colors:Variant, size:=1.0) -> void:
	if colors is Color:
		for p:Vector3 in points:
			_add_sphere(p, colors, size)
	elif colors is Array[Color]:
		for i:int in points.size():
			_add_sphere(points[i], colors[i], size)

# points = array of arrays: [position, color, size]
func bulk_spheres(points:Array) -> void:
	for p:Array in points:
		_add_sphere(p[0], p[1], p[2])




func circle(position:Vector3, radius:float, axis:Vector3, color:Color, thickness:=1.0) -> void:
	var points := _create_circle_points(position, radius, axis, color)
	points.append(points[0])
	polyline(points, color, thickness)

func bulk_circles(circles:Array) -> void:
	for c:Array in circles:
		circle(c[0], c[1], c[2], c[3], c[4])




func text(position:Vector3, string:String, color:Color, size:=1.0) -> void:
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


func _init(_name:Variant=null) -> void:
	if name:
		assert(_name is String)  # TODO: or use 'typeof()'?
		name = "DebugDrawTool3D" if not _name else _name
#	_create_materials()


func _ready() -> void:
	_init_config()

	name = "DrawTool3D"
	backline_color = Color(line_color.darkened(darken_factor), back_alpha)
	face_color     = Color(line_color, face_alpha)
	backface_color = Color(face_color.darkened(darken_factor), back_alpha)

	_label_nodes = Node3D.new()
	add_child(_label_nodes)
	_label_nodes.name = "3d_labels"

	_init_im()
	_init_mmis()


func _init_config() -> void:
	var data: Node = load("res://addons/sk_debug_tools/data.gd").new()

	if not FileAccess.file_exists(data.DT_SETTINGS_PATH):
		return

	var config := load(data.DT_SETTINGS_PATH)

	#line_color               = config.line_color
	#backline_color           = config.backline_color
	#face_color               = config.face_color
	#backface_color           = config.backface_color
	#line_thickness           = config.line_thickness
	unshaded                 = config.unshaded
	on_top                   = config.on_top
	#no_shadows               = config.no_shadows
	#transparent              = config.transparent
	#double_sided             = config.double_sided
	#back_alpha               = config.back_alpha
	#face_alpha               = config.face_alpha
	#darken_factor            = config.darken_factor
	#see_through              = config.see_through
	width_factor             = config.width_factor
	sphere_radial_segments   = config.sphere_radial_segments
	sphere_rings             = config.sphere_rings
	circle_segments          = config.circle_segments
	cylinder_radial_segments = config.cylinder_radial_segments
	instance_increment       = config.instance_increment


func _init_im() -> void:
	if not see_through:
		_im_base_mat = _create_material(face_color)
		_im_base_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
	else:
		_im_fore_mat = _create_material(face_color)
		_im_fore_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
		_im_fore_mat.no_depth_test = false

		_im_base_mat = _create_material(backface_color)
		_im_base_mat.cull_mode = BaseMaterial3D.CULL_DISABLED if double_sided else BaseMaterial3D.CULL_BACK
		_im_base_mat.render_priority = -1
		_im_base_mat.next_pass = _im_fore_mat
		_im_base_mat.no_depth_test = true

	_im = ImmediateMesh.new()
	var mi := MeshInstance3D.new()
	mi.name = "Faces_MeshInstance3D"
	mi.mesh = _im
	mi.material_override = _im_base_mat
	add_child(mi)


func _init_mmis() -> void:
	if not see_through:
		_base_mat = _create_material(line_color)
	else:
		_fore_mat = _create_material(line_color)
		_fore_mat.no_depth_test = false

		_base_mat = _create_material(backline_color)
		_base_mat.render_priority = -1
		_base_mat.next_pass = _fore_mat
		_base_mat.no_depth_test = true

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
#	mat.render_priority = render_priority

	if unshaded:    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	else:           mat.shading_mode = BaseMaterial3D.SHADING_MODE_PER_PIXEL
	if transparent or see_through: mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	else:                          mat.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED

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
	var cone := CylinderMesh.new()
	cone.top_radius = 0
	cone.bottom_radius = width_factor*4
	cone.height = 0.04
	cone.radial_segments = sphere_radial_segments
	cone.rings = 0
	cone.material = mat

	return _create_multimesh(cone, "Cones_MultiMeshInstance3D")


func _init_sphere_mesh(mat:StandardMaterial3D) -> MultiMesh:
	# ----------------------------------------
	# create spheres
	var sphere := SphereMesh.new()
	sphere.radius = width_factor
	sphere.height = width_factor*2
	sphere.radial_segments = sphere_radial_segments
	sphere.rings = sphere_rings
	sphere.material = mat

	return _create_multimesh(sphere, "Spheres_MultiMeshInstance3D")


#func _create_materials() -> void:
#	_mat1 = StandardMaterial3D.new()
##	_mat1.vertex_color_use_as_albedo = true
#	_mat1.flags_unshaded = true
#	_mat1.no_depth_test = true
#	_mat1.disable_receive_shadows = true
#	_mat1.flags_transparent = true
#	_mat1.albedo_color = Color(1,1,1,0.25)
#	_mat1.render_priority = -1
#
#	_mat2 = StandardMaterial3D.new()
#	_mat2.vertex_color_use_as_albedo = true
#	_mat2.flags_unshaded = unshaded
#	_mat2.no_depth_test = false
#	_mat2.disable_receive_shadows = true
#	_mat2.flags_transparent = true
#	_mat2.albedo_color = Color.WHITE
##
#	_mat1.next_pass = _mat2
#	_mat2.next_pass = _mat2


#func _create_materials():
#	_mat1 = StandardMaterial3D.new()
#	_mat1.vertex_color_use_as_albedo = true
#	_mat1.flags_unshaded = unshaded
#	_mat1.no_depth_test = true
#	_mat1.disable_receive_shadows = true
#	_mat1.flags_transparent = _USE_TRANSPARENCY
#	_mat1.albedo_color = Color(1,1,1, _MAX_ALPHA) if _USE_TRANSPARENCY else Color.WHITE
#
##	if outlines:
##		var np_mat := StandardMaterial3D.new()
##		np_mat.flags_unshaded = unshaded
##		np_mat.disable_receive_shadows = true
##		np_mat.no_depth_test = true
##		np_mat.albedo_color = Color.BLACK
##		np_mat.params_grow = true
##		np_mat.params_grow_amount = 0.005
##		np_mat.render_priority = -1
##
##		_mat1.next_pass = np_mat



#var shaded:BaseMaterial3D.ShadingMode:
##	get: return _mat1.flags_unshaded
##	set(enabled): _mat1.flags_unshaded = enabled
#	get: return _mat1.shading_mode
#	set(mode): _mat1.shading_mode = mode
#
#var on_top:bool:
#	get: return _mat2.no_depth_test
#	set(enabled): _mat2.no_depth_test = enabled


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
	add_child(mmi)
	return mm

#endregion initialization


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    Internal API

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
#region Internal API
func _create_circle_points(position:Vector3, radius:float, axis:Vector3, _color:Color) -> Array:
	axis = axis.normalized()

	# TODO: when the axis used in the cross product below is the same
	# as the circle's axis, use a perpendicular axis instead
	var _cross_axis := Vector3.RIGHT
	if axis == _cross_axis:
		_cross_axis = Vector3.UP
		#if _cross_axis == Vector3.RIGHT:
			#_cross_axis = Vector3.UP
		#elif _cross_axis == Vector3.UP:
			#_cross_axis = Vector3.RIGHT

	var points := []
	var cross := axis.cross(_cross_axis).normalized() *  radius

	# this was intended for some edge cases, but it seems like it never happens
	var dot :float = abs(cross.dot(axis))
	if dot > 0.9:
		printerr(_create_circle_points, ": THIS CODE HAS RUN!") # seems like this code never runs
		cross = axis.cross(Vector3.UP) * radius

#	print(axis, cross, dot)

	# draw a debug cross-product vector
	#line(position, position+cross, _color, 2)
	#cone(position+cross, cross, _color, 2)

	for r:int in range(0, 360, 360/float(circle_segments)):
		var c := cross.rotated(axis, deg_to_rad(r)).normalized()
		var p := position + c * radius
		points.append(p)

	return points


func _create_circle_points_OLD(position:Vector3, radius:Vector3, axis:Vector3) -> Array:
	var points := []

	for r:int in range(0, 360, 360/float(sphere_radial_segments)):
		var p := position + radius.rotated(axis, deg_to_rad(r))
		points.append(p)

	return points


# http://kidscancode.org/godot_recipes/3.x/3d/3d_align_surface/
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
	mm.visible_instance_count += 1

	# if the visible count reaches the instance count, then more instances are needed
	if mm.instance_count <= mm.visible_instance_count:
		# this is enough to make the MultiMesh create more instances internally
		mm.instance_count += instance_increment

	return idx


func _commit_instance(mm:MultiMesh, idx:int, transform:Transform3D, color:Color) -> void:
	mm.set_instance_transform(idx, transform)
	# TODO: check what to do about this when using 'single_color'
	mm.set_instance_color(idx, color)



func _add_line(a:Vector3, b:Vector3, color:=line_color, thickness:=line_thickness) -> void:
	if _use_cylinders_for_lines:
		_add_line_cylinder(a, b, color, thickness)
	else:
		_add_line_cube(a, b, color, thickness)




func _points_are_equal(a:Vector3, b:Vector3) -> bool:
	if a != b: return false
#	push_warning("points 'a' and 'b' are the same: %s == %s" % [a, b])
	return true


func _add_line_cube(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	# I had issues here with 'looking_at', which I can't quite remember,
	# but I solved somehow. I posted it here:
	#     https://godotforums.org/d/27860-transform-looking-at-not-working
	# I found a potentially better solution instead of 'looking_at', used
	# below, in the cylinder line function

	if _points_are_equal(a, b): return

	var mm:MultiMesh = _mms["cube_lines"]

	# adding an instance is basically just raising the visible_intance_count
	# and then using that index to get and set properties of the instance
	var idx := _add_instance_to(mm)

	# if transform is to be orthonormalized, do it here beback applying any
	# scaling, or it will revert the scaling
	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
#	var transform := Transform()
	transform.origin = (a+b)/2

	var target_direction := (b-transform.origin).normalized()
	transform = transform.looking_at(b,
		Vector3.UP if abs(target_direction.dot(Vector3.UP)) < _DOT_THRESHOLD
		else Vector3.BACK
	)

	# TODO: this probably accumulates scaling if this instance was scaled beback,
	#       but I've never seen any issues, so... I could be wrong.
	transform.basis.x *= thickness
	transform.basis.y *= thickness
	transform.basis.z *= a.distance_to(b) + width_factor * thickness

	_commit_instance(mm, idx, transform, color)


func _add_line_cylinder(a:Vector3, b:Vector3, color:Color, thickness:=1.0) -> void:
	if _points_are_equal(a, b): return

	var mm:MultiMesh = _mms["cylinder_lines"]
	var idx := _add_instance_to(mm)

	var transform := Transform3D() # mm.get_instance_transform(idx).orthonormalized()
	transform.origin = (a+b)/2

	var target_direction := (b-transform.origin).normalized()

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


func _add_cone(position:Vector3, direction:Vector3, color:Color, length:=3.0, thickness:=1.0) -> void:
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


func _add_sphere(position:Vector3, color:Color, size:=1.0) -> void:
	var mm:MultiMesh = _mms["spheres"]

	var idx := _add_instance_to(mm)
#	var transform := mm.get_instance_transform(idx).orthonormalized()
	var transform := Transform3D()

	transform.origin = position
	transform.basis = transform.basis.scaled(Vector3.ONE * size)

	_commit_instance(mm, idx, transform, color)


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
