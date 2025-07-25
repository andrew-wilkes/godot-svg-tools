extends Node2D

func _ready() -> void:
	draw_lines()
	draw_svg("res://assets/example.svg")


func draw_svg(file_path: String):
	var svg_points = SVGPoints.new()
	var nodes = Helpers.get_xml_nodes(file_path)
	var translation = Vector2(10, 10)
	for node in nodes:
		for attribs in nodes[node]:
			var points: SVGPoints.ReturnPoints
			match node:
				"rect":
					points = svg_points.get_rectangle(attribs)
				"circle":
					points = svg_points.get_circle(attribs)
				"ellipse":
					points = svg_points.get_ellipse(attribs)
				"line":
					points = svg_points.get_line(attribs)
				"polyline":
					points = svg_points.get_polyline(attribs)
				"polygon":
					points = svg_points.get_polygon(attribs)
				"path":
					points = svg_points.get_path_line(attribs)
				"g":
					translation += svg_points.get_translation(attribs)
			if points:
				add_line_node(points, translation, 4.0)
		

func draw_lines():
	var svg_points = SVGPoints.new()
	var attribs = {}
	attribs["width"] = 200
	attribs["height"] = 100
	attribs["x"] = 50
	attribs["y"] = 20
	var result = svg_points.get_rectangle(attribs)
	if result.error:
		print("Error with get_rectangle 1")
	else:
		add_line_node(result)
	attribs["x"] = 50
	attribs["y"] = 140
	attribs["rx"] = 40
	attribs["ry"] = 20
	result = svg_points.get_rectangle(attribs)
	if result.error:
		print("Error with get_rectangle 2")
	else:
		add_line_node(result)
	attribs["cx"] = 200
	attribs["cy"] =390
	attribs["r"] = 60
	result = svg_points.get_circle(attribs)
	if result.error:
		print("Error with get_circle")
	else:
		add_line_node(result)
	attribs["cx"] = 250
	attribs["cy"] = 400
	attribs["rx"] = 30
	attribs["ry"] = 100
	result = svg_points.get_ellipse(attribs)
	if result.error:
		print("Error with get_ellipse")
	else:
		add_line_node(result)
	attribs["x1"] = 300
	attribs["y1"] = 60
	attribs["x2"] = 800
	attribs["y2"] = 160
	result = svg_points.get_line(attribs)
	if result.error:
		print("Error with get_line")
	else:
		add_line_node(result)
	attribs["points"] = "100,10 150,190 50,190"
	result = svg_points.get_polygon(attribs, Vector2(300, 400))
	if result.error:
		print("Error with get_polygon 1")
	else:
		add_line_node(result)
	attribs["points"] = "100,10 40,198 190,78 10,78 160,198"
	result = svg_points.get_polygon(attribs, Vector2(500, 400))
	if result.error:
		print("Error with get_polygon 2")
	else:
		add_line_node(result)
	attribs["points"] = "0,0 50,150 100,75 150,50 200,140 250,140"
	result = svg_points.get_polyline(attribs, Vector2(400, 100))
	if result.error:
		print("Error with get_polyline")
	else:
		add_line_node(result)
	attribs["d"] = "M300 270 l50 100 l50 -100 h50 v80 h10 c 10,50 90,50 100,0 s 90,-50 100,0 q50,100 100,0 t100,0 t 100 0"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 1")
	else:
		add_line_node(result)
	attribs["d"] = "M800 200 a100 150 0 1 0 300 0 h20 L 800 200"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 2")
	else:
		add_line_node(result)
	attribs["d"] = "M500 200 30 30 0 100 m 20 0 l 50 50 30 0 v 10 50 40 h 50 50"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 3")
	else:
		add_line_node(result, Vector2.ZERO, 1.0, Color.BLUE)
	attribs["d"] = "M500 150 C500 100 550 100 550 150 550 200 600 200 600 150 S650 100 650 150 700 200 700 150"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 4")
	else:
		add_line_node(result, Vector2.ZERO, 1.0, Color.GREEN)
	attribs["d"] = "m 500 100 q 50 100 100 00 50 50 100 0 t100 0 100 0"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 5")
	else:
		add_line_node(result, Vector2.ZERO, 1.0, Color.RED)
	attribs["d"] = "m 500 400 a 20 50 30 0 0 60 0 20 50 -30 1 1 60 0"
	result = svg_points.get_path_line(attribs)
	if result.error:
		print("Error with get_path_line 6")
	else:
		add_line_node(result, Vector2.ZERO, 1.0, Color.YELLOW)
	test_elliptic_arc_point(svg_points)


func add_line_node(params: SVGPoints.ReturnPoints, translation: Vector2 = Vector2.ZERO, scale_factor: float = 1.0, color: Color = Color.WHITE):
	for idx in params.points.size():
		params.points[idx] += translation + params.position
		params.points[idx] *= scale_factor
	var line: Line2D = Line2D.new()
	line.width = 2.0
	line.default_color = Color.WHITE
	line.points = params.points
	line.closed = params.close
	line.default_color = color
	add_child(line)


func test_elliptic_arc_point(svg_points: SVGPoints):
	var num_points = 100
	var astep = TAU / num_points
	var line = Line2D.new()
	line.width = 2
	line.closed = false
	var ang = 0.0
	var cp = Vector2(900, 400)
	for n in num_points:
		ang += astep
		var point = svg_points.elliptic_arc_point(cp, Vector2(100, 200), PI/4.0, ang)
		line.add_point(point)
		ang += astep
	add_child(line)
