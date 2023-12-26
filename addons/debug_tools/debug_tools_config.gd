class_name DebugToolsConfig
extends Resource

## The configuration file for the Debug Tools Addon


#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    	General

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
@export_category("CanvasLayers")

## The CanvasLayer the info panel uses. Keep it high enough so the panel
## can be displayed in front of everything else.
@export var info_tool_layer := 128

## The CanvasLayer the 2D drawing tool uses. Keep it high enough so the tool
## can draw over everything else, except the debug tools that rely on
## GUI elements, like the info panel.
@export var drawing_tool_layer := 125



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    	Info Tool

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
@export_category("Info Display")

## The float precision that will be used when no precision is specified
## in calls to DevTool.print().
## NOTE: this doesn't affect the way Vectors, Rects, etc, are displayed.
@export_range(0, 16) var float_precision :int = 2


#-------------------------------------------------------------------------------
@export_group("Background")
#-------------------------------------------------------------------------------

## Whether or not to draw the background panel.
@export var draw_background := true

## Whether or not to draw the background panel's border.
@export var draw_border := true

## The color of the background panel.
@export var background_color := Color("1a1a1a99")

## The width of the background panel's border.
@export_range(0, 200) var border_width := 1

## The color of the background panel's border.
@export var border_color := Color("ffffff5d")


#-------------------------------------------------------------------------------
@export_group("Text")
#-------------------------------------------------------------------------------

## The size of all the text displayed in the info panel.
@export_range(1, 1000) var text_size := 16

## The size of the outline around the text. You can set this to 0 to turn off
## outlines.
@export_range(0, 500) var outline_size := 10


#-------------------------------------------------------------------------------
@export_group("Text Colors")
#-------------------------------------------------------------------------------

## The color of keys text
@export var key_color := Color.LIGHT_GRAY

## The color of group names
@export var group_color := Color(1, 0.37, 0.37)

## The color of null values
@export var null_color := Color.FUCHSIA

## The color of number values
@export var number_color := Color(0.81, 0.64, 0.99)

## The color of string values
@export var string_color := Color(1, 0.90, 0.66)

## The color of bool values
@export var bool_color := Color(1, 0.72, 0.26)

## The color of built-in type values (Vectors, Arrays, AABBs, etc)
@export var builtin_color := Color(0.74, 0.84, 1)

## The color of object values
@export var object_color := Color(0.30, 0.86, 0.30)



#-------------------------------------------------------------------------------
@export_group("Benchmarking")
#-------------------------------------------------------------------------------

## The smoothing value the benchmark function will use by default. This can
## prevent values that fluctuate too much from being unreadable.
## Higher values mean less fluctuation but less accuracy.
@export var smoothing := 15

## The maximum smoothing that can be applied to benchmarking reports. Smoothing
## is done by keeping a history of reports and averaging them over time. This
## value is effectively how big the array is. Values are added and removed from
## this array every frame, and the elements have to be shifted.
@export var max_smoothing := 100

## If true, benchmark times will be reported in seconds. Otherwise
## they'll be in milliseconds.
@export_enum("Seconds", "Milliseconds") var time_units := 1

## The float precision of benchmarking values.
@export var decimal_precision := 4



#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=

#    	Drawing

#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=#=
@export_category("3D Drawing")

## How many new instances should be added to the MultiMeshInstance's pool when
## the pool is full.
## May be better to leave this unchanged if you don't know what that means.
@export var instance_increment := 16

## The fraction of a 3d unit that represents a line thickness of 1. Higher
## values mean thicker lines.
## Lines will look too thick or too thin when viewed from too close or too far,
## and this value can be tweaked to accomodate for different use cases.
@export var width_factor := 0.01


#-------------------------------------------------------------------------------
@export_group("Geometry")
#-------------------------------------------------------------------------------

## Whether lines are affected by lighting or not. (Ideally this is better kept
## off. I have the option available only because the shaded lines can actually
## look quite nice, depending on lighting. But they will be invisible, or hard
## to see without lighting.)
@export var unshaded := true

## If true, the 3D drawing tool will draw on top of everything. Otherwise
## the drawing may be obstructed by other geometry. (Leaving it on can make
## it confusing to see where things actually are.)
@export var on_top := false

## If true, the geometry will cast shadows. For most debugging/development
## purposes it's usually better to keep this off.
@export var cast_shadows := false


#-------------------------------------------------------------------------------
@export_group("Shapes")
#-------------------------------------------------------------------------------

## How many radial segments the spheres will be made of (the vertical lines)
@export_range(3, 128) var sphere_radial_segments := 24

## How many rings the spheres will be made of (the horizontal lines)
@export_range(2, 128) var sphere_rings := 12

## How many radial segments the wireframe spheres will be made of (the vertical lines)
@export_range(4, 128) var hollow_sphere_radial_segments := 8

## How many rings the wireframe spheres will be made of (the horizontal lines)
@export_range(2, 128) var hollow_sphere_rings := 6


## How many line segments the circles will be made of
@export_range(4, 128) var circle_segments := 32

## How many radial segments the cylinders will be made of (the vertical lines)
## NOTE: cylinders are not being used for anything yet.
@export_range(4, 128) var cylinder_radial_segments := 5


#-------------------------------------------------------------------------------
@export_group("Colors")
#-------------------------------------------------------------------------------

## The color used for lines that represent the X axis (in transforms, origins, etc)
@export var x_axis_color := Color(0.72, 0.02, 0.02)

## The color used for lines that represent the Y axis (in transforms, origins, etc)
@export var y_axis_color := Color(0.025, 0.31, 0)

## The color used for lines that represent the Z axis (in transforms, origins, etc)
@export var z_axis_color := Color(0, 0.10, 1)

## How much to darken the axis colors when drawing the negative side of an origin.
@export var negative_darken_factor := 0.75




