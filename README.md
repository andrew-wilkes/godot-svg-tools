# Godot SVG Tools
Useful code for anyone using Godot who needs to implement SVG decoding to vectors etc.

Scalable Vector Graphic (SVG) files are exported from 2D graphic design programs such as Inkscape. They describe 2D geometry and styling so may be scaled without affecting the image quality.

These files may be used as textures in Godot Nodes directly, but it can be useful to extract the data and create arrays of points in order to construct lines or arrays of vertices for various use cases.

The **SVGPoints** class is used to translate SVG commands that are extracted from an SVG file for shapes and paths to **Vector2** points.

## Reference Links
[Scalable Vector Graphics (SVG) 1.1 Specification](https://www.w3.org/TR/SVG11/)
