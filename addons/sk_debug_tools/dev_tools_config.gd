class_name DevToolsConfig
extends Resource

# NOTE (TODO): some of the 3D drawing settings are commented out because
# I don't quite remember exactly how they work, since I've not been working on
# or using the drawing tool for many months now.
# I'll have to recap and see what's useful for the plugin.



@export_category("CanvasLayers")

## The CanvasLayer the info panel uses. Keep it high enough so the panel
## can be displayed in front of everything else.
@export var info_tool_layer := 128

## The CanvasLayer the 2D drawing tool uses. Keep it high enough so the tool
## can draw over everything else, except the DevTools that rely on GUI elements,
## like the info panel.
@export var drawing_tool_layer := 125



@export_category("Info Display")

## The size of all the text displayed in the info panel.
@export_range(1, 1000) var text_size := 16

## The float precision that will be used when no precision is specified
## in calls to DevTool.print().
## NOTE: this doesn't affect the way Vectors, Rects, etc, are displayed.
@export_range(0, 16) var default_float_precision :int = 2

## The size of the outline around the text. You can set this to 0 to turn off
## outlines.
@export_range(0, 500) var outline_size := 10

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

## The color of key text (left side)
@export var key_color := Color.LIGHT_GRAY

## The color of group names (left side)
@export var group_color := Color(1, 0.37, 0.37)

## The color of null values (right side)
@export var null_color := Color.FUCHSIA

## The color of number values (right side)
@export var number_color := Color(0.81, 0.64, 0.99)

## The color of string values (right side)
@export var string_color := Color(1, 0.90, 0.66)

## The color of bool values (right side)
@export var bool_color := Color(1, 0.72, 0.26)

## The color of builtin values (right side)
@export var builtin_color := Color(0.74, 0.84, 1)

## The color of object values (right side)
@export var object_color := Color(0.30, 0.86, 0.30)




@export_category("3D Drawing")

## How many instances to add to the MultiMeshInstance when more instances
## are needed in the pool. If you don't know what this means, just leave it
## as it is.
@export var instance_increment := 16

## The fraction of a unit that represents a line thickness of 1.
## Lines will look too thick or too thin from too close or too far, so this
## must be tweaked according to the intended usage.
@export var width_factor := 0.01

## How many radial segments the spheres will be made of (the vertical lines)
@export var sphere_radial_segments := 24

## How many rings the spheres will be made of (the horizontal lines)
@export var sphere_rings := 12

## How many line segments the circles will be made of
@export var circle_segments := 32

## How many radial segments the cylinders will be made of (the vertical lines)
## NOTE: cylinders are not being used for anything yet.
@export var cylinder_radial_segments := 5




## (iirc) If true, then all objects will use the same color and
## ignore the colors provided in the functions (not very useful here, I think)
#@export var single_color := false

#@export var line_color := Color.WHITE
#@export var backline_color:Color
#@export var face_color:Color
#@export var backface_color:Color

#@export var line_thickness := 1.0


## Whether lines are affected by lighting or not. (Ideally this is better kept
## off. I have the option available only because the shaded lines can actually
## look quite nice, depending on lighting. But they will be invisible, or hard
## to see without lighting.)
@export var unshaded := true

## If true, the 3D drawing tool will draw on top of everything. Otherwise
## the drawing may be obstructed by other geometry. (Leaving it on can make
## it confusing to see where things actually are.)
@export var on_top := false


#@export var no_shadows := true
#@export var transparent := false
#@export var double_sided := false

#@export var back_alpha := 0.5
#@export var face_alpha := 0.5
#@export var darken_factor := 0.25
#@export var see_through := false  # TODO: this doesn't seem to work reliably




