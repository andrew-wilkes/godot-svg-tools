# Godot SVG Tools
Useful code for anyone using Godot who needs to implement SVG decoding to Vectors etc.

Scalable Vector Graphic (SVG) files are exported from 2D graphic design programs such as Inkscape. They describe 2D geometry and styling so may be scaled without affecting the image quality.

These files may be used as textures in Godot Nodes directly, but it can be useful to extract the data and create arrays of points in order to construct lines or arrays of vertices for various use cases.

The **SVGPoints** class is used to translate SVG commands that are extracted from an SVG file for shapes and paths to **Vector2** points.

## Tests

A test scene (`test_svg.tscn`) exercises the code (`svg_points.gd`) to display a variety of shapes and paths.

The Addon *GDUnit4* needs to be installed to run the unit tests in (`svg_points_test.gd`).

## Limitations

Only very basic transforms are supported such as `translate` in a `g` block. Nested transforms are not implemented.

Scaling is done by a hard-coded factor in the test code.

## Reference Links
[Scalable Vector Graphics (SVG) 1.1 Specification](https://www.w3.org/TR/SVG11/)

[SVG from scratch](https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch)