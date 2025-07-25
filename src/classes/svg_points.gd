class_name SVGPoints
extends RefCounted

class ReturnPoints:
	var error: bool
	var position: Vector2
	var points: PackedVector2Array
	var close: bool

class ReturnNum:
	var error: bool
	var idx: int
	var num: float

class ReturnCoor:
	var error: bool
	var idx: int
	var coor: Vector2

class ReturnArc:
	var theta: float
	var delta: float
	var center: Vector2
	var radius: Vector2

enum NumType {
	NOT_KNOWN,
	SIGNED,
	INT,
	FRACT,
	FP,
	FPS
}

enum CmdType {
	OTHER,
	CUBIC,
	QUAD,
}

func parse_num(token_str: String, idx: int) -> ReturnNum:
	var rnum = ReturnNum.new()
	var chrs = []
	var num_type = NumType.NOT_KNOWN
	while true:
		if idx == token_str.length():
			rnum.error = true
			return rnum
		var ch = token_str[idx]
		idx += 1
		match num_type:
			NumType.NOT_KNOWN:
				match ch:
					"+":
						num_type = NumType.SIGNED
					"-":
						chrs.append(ch)
						num_type = NumType.SIGNED
					".":
						chrs.append("0")
						chrs.append(ch)
						num_type = NumType.FRACT
					var x when x in "0123456789":
						chrs.append(ch)
						num_type = NumType.INT
						if idx == token_str.length():
							break
					var x when x not in " ,":
						rnum.error = true
						return rnum
			NumType.SIGNED:
				match ch:
					".":
						chrs.append("0")
						chrs.append(ch)
						num_type = NumType.FRACT
					"E", "e":
						chrs.append(ch)
						num_type = NumType.FP
					var x when x in "0123456789":
						chrs.append(ch)
						num_type = NumType.INT
					var x when x != " ":
						rnum.error = true
						return rnum
				if idx == token_str.length():
					break
			NumType.INT:
				match ch:
					".":
						chrs.append(ch)
						num_type = NumType.FRACT
						if idx == token_str.length():
							chrs.append("0")
							break
					"E", "e":
						chrs.append(ch)
						num_type = NumType.FP
					var x when x in "0123456789":
						chrs.append(ch)
						if idx == token_str.length():
							break
					var x when x in " ,":
						break # Got number chrs
					_:
						idx -= 1 # Terminated by possibly a new command
						break
			NumType.FRACT:
				match ch:
					var x when x in "0123456789":
						chrs.append(ch)
						if idx == token_str.length():
							break
					var x when x in " ,":
						break # Got number chrs
					_:
						idx -= 1 # Terminated by possibly a new command
						break
			NumType.FP:
				match ch:
					"+":
						num_type = NumType.FPS
					"-":
						chrs.append(ch)
						num_type = NumType.FPS
					var x when x in "0123456789":
						chrs.append(ch)
						if idx == token_str.length():
							break
					var x when x in " ,":
						break # Got number chrs
					_:
						idx -= 1 # Terminated by possibly a new command
						break
			NumType.FPS:
				match ch:
					var x when x in "0123456789":
						chrs.append(ch)
						if idx == token_str.length():
							break
					var x when x in " ,":
						break # Got number chrs
					_:
						idx -= 1 # Terminated by possibly a new command
						break
	if chrs.size() == 0:
		rnum.error = true
		return rnum
	if chrs[-1] == ".":
		chrs.append(0)
	rnum.error = false
	rnum.idx = idx
	rnum.num = float("".join(chrs))
	return rnum


func get_coor(token_str: String, idx: int) -> ReturnCoor:
	var coor = ReturnCoor.new()
	var result = parse_num(token_str, idx)
	if result.error:
		coor.error = true
		return coor
	coor.coor.x = float(result.num)
	result = parse_num(token_str, result.idx)
	if result.error:
		coor.error = true
		return coor
	coor.coor.y = float(result.num)
	coor.idx = result.idx
	return coor


func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	var r = q0.lerp(q1, t)
	return r


func get_translation(attribs: Dictionary):
	var txt: String = attribs.get("transform", "")
	if txt.begins_with("translate("):
		var from = txt.find("(") + 1
		var coors = get_coor(txt.substr(from, txt.find(")") - from), 0)
		if not coors.error:
			return coors.coor
	return Vector2.ZERO


func get_rectangle(attribs: Dictionary) -> ReturnPoints:
	var width = float(attribs.get("width", 0.0))
	var height = float(attribs.get("height", 0.0))
	var x = float(attribs.get("x", 0.0))
	var y = float(attribs.get("y", 0.0))
	var rx = float(attribs.get("rx", 0.0))
	var ry = float(attribs.get("ry", 0.0))
	if rx < 0.001 and ry > 0.001:
		rx = ry
	elif ry < 0.001 and rx > 0.001:
		ry = rx
	var res = int(sqrt(rx * ry))
	var rect = ReturnPoints.new()
	if res == 0: # No need to round the corners
		rect.points.append(Vector2(0,0))
		rect.points.append(Vector2(width,0))
		rect.points.append(Vector2(width, height))
		rect.points.append(Vector2(0, height))
	else:
		if res % 2 == 0:
			res += 1 # Have an odd number of steps
		var tstep = 1.0 / (res - 1)
		var p1 = Vector2(0, ry)
		var p2 = Vector2(0, 0)
		var p3 = Vector2(rx, 0)
		var t = 0
		for n in res:
			rect.points.append(quadratic_bezier(p1, p2, p3, t))
			t += tstep
		p1 = Vector2(width - rx, 0)
		p2 = Vector2(width, 0)
		p3 = Vector2(width, ry)
		t = 0
		for n in res:
			rect.points.append(quadratic_bezier(p1, p2, p3, t))
			t += tstep
		p1 = Vector2(width, height - ry)
		p2 = Vector2(width, height)
		p3 = Vector2(width-rx, height)
		t = 0
		for n in res:
			rect.points.append(quadratic_bezier(p1, p2, p3, t))
			t += tstep
		p1 = Vector2(rx, height)
		p2 = Vector2(0, height)
		p3 = Vector2(0, height - ry)
		t = 0
		for n in res:
			rect.points.append(quadratic_bezier(p1, p2, p3, t))
			t += tstep
	rect.position = Vector2(x, y)
	rect.close = true
	return rect


func get_circle(attribs: Dictionary) -> ReturnPoints:
	var cx = float(attribs.get("cx", 0.0))
	var cy = float(attribs.get("cy", 0.0))
	var r = float(attribs.get("r", 0.0))
	var circle = ReturnPoints.new()
	if r < 0.001:
		circle.error = true
		return circle
	var radius = Vector2(r, r)
	var cp = Vector2(cx, cy)
	var res = maxi(int(r), 16)
	var astep = TAU / res
	var ang = 0.0
	for n in res + 1:
		circle.points.append(elliptic_arc_point(cp, radius, 0, ang))
		ang += astep
	return circle


func get_ellipse(attribs: Dictionary) -> ReturnPoints:
	var cx = float(attribs.get("cx", 0.0))
	var cy = float(attribs.get("cy", 0.0))
	var rx = float(attribs.get("rx", 0.0))
	var ry = float(attribs.get("ry", 0.0))
	var ellipse = ReturnPoints.new()
	if min(rx, ry) < 0.001:
		ellipse.error = true
		return ellipse
	var res = maxi(int(sqrt(rx * ry)), 16)
	var ang = 0.0
	var astep = TAU /res
	var cp = Vector2(cx, cy)
	var r = Vector2(rx, ry)
	for n in res + 1:
		ellipse.points.append(elliptic_arc_point(cp, r, 0, ang))
		ang += astep
	return ellipse


func get_line(attribs: Dictionary) -> ReturnPoints:
	var x1 = float(attribs.get("x1", 0.0))
	var y1 = float(attribs.get("y1", 0.0))
	var x2 = float(attribs.get("x2", 0.0))
	var y2 = float(attribs.get("y2", 0.0))
	var line = ReturnPoints.new()
	line.points.append(Vector2(x1, y1))
	line.points.append(Vector2(x2, y2))
	return line


func get_polyline(attribs: Dictionary, pos: Vector2 = Vector2.ZERO) -> ReturnPoints:
	var points_str = String(attribs.get("points", ""))
	var points = points_str.split(" ")
	var poly = ReturnPoints.new()
	if points.size() == 0:
		poly.error = true
		return poly
	for pair in points:
		var nums = pair.split(",")
		if nums.size() == 2:
			poly.points.append(Vector2(int(nums[0]), int(nums[1])))
	poly.position = pos
	return poly


func get_polygon(attribs: Dictionary, pos: Vector2 = Vector2.ZERO) -> ReturnPoints:
	var res = get_polyline(attribs, pos)
	res.close = true
	return res


func get_path_line(attribs: Dictionary) -> ReturnPoints:
	"""
		Commands:
		M = moveto (move from one point to another point)
		L = lineto (create a line)
		H = horizontal lineto (create a horizontal line)
		V = vertical lineto (create a vertical line)
		C = curveto (create a curve)
		S = smooth curveto (create a smooth curve)
		Q = quadratic Bézier curve (create a quadratic Bézier curve)
		T = smooth quadratic Bézier curveto (create a smooth quadratic Bézier curve)
		A = elliptical Arc (create an elliptical arc)
		Z = closepath (close the path)

	Note: All of the commands above can also be expressed in lower case. Upper case means absolutely positioned, lower case means relatively positioned.

	See: https://developer.mozilla.org/en-US/docs/Web/SVG/Tutorials/SVG_from_scratch/Paths
	https://www.smashingmagazine.com/2025/06/decoding-svg-path-element-curve-arc-commands/
	https://raw.org/proof/svg-arc-to-gcode-g2-and-g3/
	https://mortoray.com/rendering-an-svg-elliptical-arc-as-bezier-curves/
	https://www.w3.org/TR/SVG11/single-page.html#implnote-ArcImplementationNotes
	http://www.spaceroots.org/documents/ellipse/elliptical-arc.pdf
	https://stackoverflow.com/questions/41537950/converting-an-svg-arc-to-lines
	https://stackoverflow.com/questions/14399406/implementing-svg-arc-curves-in-python
	"""
	var tokens_str = String(attribs.get("d", ""))
	var line = ReturnPoints.new()
	var pos = Vector2.ZERO
	var last_control_point = pos
	var last_cmd_type = CmdType.OTHER
	var idx = 0
	while idx < tokens_str.length():
		var ch = tokens_str[idx]
		idx += 1
		match ch:
			"M", "m":
				var coor = get_coor(tokens_str, idx)
				if coor.error:
					break
				idx = coor.idx
				if ch == "M":
					pos = coor.coor
				else:
					pos += coor.coor
				line.points.append(pos)
				# Subsequent coordinates up to the next cmd are treated as "l" commands
				while true:
					coor = get_coor(tokens_str, idx)
					if coor.error:
						break
					pos += coor.coor
					line.points.append(pos)
					idx = coor.idx
				last_control_point = Vector2.ZERO
				last_cmd_type = CmdType.OTHER
			"L", "l":
				while true:
					var coor = get_coor(tokens_str, idx)
					if coor.error:
						break
					idx = coor.idx
					if ch == "L":
						pos = coor.coor
					else:
						pos += coor.coor
					line.points.append(pos)
				last_control_point = Vector2.ZERO
				last_cmd_type = CmdType.OTHER
			"H", "h":
				while true:
					var coor = parse_num(tokens_str, idx)
					if coor.error:
						break
					idx = coor.idx
					var x = float(coor.num)
					if ch == "H":
						pos = Vector2(x, pos.y)
					else:
						pos =  Vector2(x + pos.x, pos.y)
					line.points.append(pos)
				last_control_point = Vector2.ZERO
				last_cmd_type = CmdType.OTHER
			"V", "v":
				while true:
					var coor = parse_num(tokens_str, idx)
					if coor.error:
						break
					idx = coor.idx
					var y = float(coor.num)
					if ch == "V":
						pos = Vector2(pos.x, y)
					else:
						pos =  Vector2(pos.x, y + pos.y)
					line.points.append(pos)
				last_control_point = Vector2.ZERO
				last_cmd_type = CmdType.OTHER
			"C", "c":
				while true:
					var c1 = get_coor(tokens_str, idx)
					if c1.error:
						break
					var c2 = get_coor(tokens_str, c1.idx)
					if c2.error:
						break
					var end = get_coor(tokens_str, c2.idx)
					if end.error:
						break
					idx = end.idx
					# Godot Curve2D control points are relative to their associated point
					c2.coor -= end.coor
					if ch == "C":
						c1.coor -= pos
					else:
						end.coor += pos
					var curve = Curve2D.new()
					curve.add_point(pos, Vector2.ZERO, c1.coor)
					curve.add_point(end.coor, c2.coor)
					pos = end.coor
					var points = curve.tessellate()
					var skip_first = true
					for point in points:
						if skip_first:
							skip_first = false
							continue
						line.points.append(point)
					last_control_point = c2.coor
				last_cmd_type = CmdType.CUBIC
			"S", "s":
				while true:
					var c1 = -last_control_point if last_cmd_type == CmdType.CUBIC else Vector2.ZERO
					var c2 = get_coor(tokens_str, idx)
					if c2.error:
						break
					var end = get_coor(tokens_str, c2.idx)
					if end.error:
						break
					idx = end.idx
					c2.coor -= end.coor
					if ch == "s":
						end.coor += pos
					var curve = Curve2D.new()
					curve.add_point(pos, Vector2.ZERO, c1)
					curve.add_point(end.coor, c2.coor)
					pos = end.coor
					var points = curve.tessellate()
					var skip_first = true
					for point in points:
						if skip_first:
							skip_first = false
							continue
						line.points.append(point)
					last_control_point = c2.coor
				last_cmd_type = CmdType.CUBIC
			"Q", "q":
				while true:
					var c1 = get_coor(tokens_str, idx)
					if c1.error:
						break
					var end = get_coor(tokens_str, c1.idx)
					if end.error:
						break
					idx = end.idx
					if ch == "Q":
						c1.coor -= pos
					else:
						end.coor += pos
					var c2 = c1.coor + pos - end.coor
					var curve = Curve2D.new()
					curve.add_point(pos, Vector2.ZERO, c1.coor)
					curve.add_point(end.coor, c2)
					pos = end.coor
					var points = curve.tessellate()
					var skip_first = true
					for point in points:
						if skip_first:
							skip_first = false
							continue
						line.points.append(point)
					last_control_point = c2
				last_cmd_type = CmdType.QUAD
			"T", "t":
				while true:
					var c1 = -last_control_point if last_cmd_type == CmdType.QUAD else Vector2.ZERO
					var end = get_coor(tokens_str, idx)
					if end.error:
						break
					idx = end.idx
					if ch == "t":
						end.coor += pos
					var c2 = c1 + pos - end.coor
					var curve = Curve2D.new()
					curve.add_point(pos, Vector2.ZERO, c1)
					curve.add_point(end.coor, c2)
					pos = end.coor
					var points = curve.tessellate()
					var skip_first = true
					for point in points:
						if skip_first:
							skip_first = false
							continue
						line.points.append(point)
					last_control_point = c2
				last_cmd_type = CmdType.QUAD
			"A", "a":
				while true:
					var rcoor = get_coor(tokens_str, idx)
					if rcoor.error:
						break
					var radius = abs(rcoor.coor)
					var xrot_num = parse_num(tokens_str, rcoor.idx)
					if xrot_num.error:
						break
					var xrot = deg_to_rad(int(xrot_num.num) % 360)
					var large_flag_num = parse_num(tokens_str, xrot_num.idx)
					if large_flag_num.error:
						break
					var large_flag: int = 0 if int(large_flag_num.num) == 0 else 1
					var sweep_num = parse_num(tokens_str, large_flag_num.idx)
					if sweep_num.error:
						break
					var sweep_flag: int = 0 if int(sweep_num.num) == 0 else 1
					var p2_coor = get_coor(tokens_str, sweep_num.idx)
					if p2_coor.error:
						break
					var p2 = p2_coor.coor
					idx = p2_coor.idx
					if ch == "a":
						p2 += pos
					if p2.is_equal_approx(pos):
						break # Don't draw the arc
					if minf(radius.x, radius.y) < 0.01:
						# Draw a line
						pos = p2
						line.points.append(pos)
						last_control_point = Vector2.ZERO
						break
					
					var ellipse = ellipse_endpoint_to_center_parameterization(pos, radius, xrot, large_flag, sweep_flag, p2)
					var res = int(sqrt(ellipse.radius.x * ellipse.radius.y))
					var astep = ellipse.delta / res
					for n in res:
						ellipse.theta += astep
						pos = elliptic_arc_point(ellipse.center, ellipse.radius, xrot, ellipse.theta)
						line.points.append(pos)
					last_control_point = pos
				last_cmd_type = CmdType.OTHER
			"Z", "z":
				line.close = true
				last_cmd_type = CmdType.OTHER
				idx += 1
	if line.points.size() == 0:
		line.error = true
	return line


func ellipse_endpoint_to_center_parameterization(start: Vector2, radius: Vector2, xrot: float, arc: bool, sweep: bool, end: Vector2):
	# http://www.w3.org/TR/SVG/implnote.html#ArcImplementationNotes
	var cosr = cos(xrot)
	var sinr = sin(xrot)
	var dx = (start.x - end.x) / 2
	var dy = (start.y - end.y) / 2
	var x1prim = cosr * dx + sinr * dy
	var x1prim_sq = x1prim * x1prim
	var y1prim = -sinr * dx + cosr * dy
	var y1prim_sq = y1prim * y1prim

	var rx = radius.x
	var rx_sq = rx * rx
	var ry = radius.y        
	var ry_sq = ry * ry

	# Correct out of range radii
	var radius_check = (x1prim_sq / rx_sq) + (y1prim_sq / ry_sq)
	if radius_check > 1:
		rx *= sqrt(radius_check)
		ry *= sqrt(radius_check)
		rx_sq = rx * rx
		ry_sq = ry * ry

	var t1 = rx_sq * y1prim_sq
	var t2 = ry_sq * x1prim_sq
	var c = sqrt((rx_sq * ry_sq - t1 - t2) / (t1 + t2))
	if arc == sweep:
		c = -c
	var cxprim = c * rx * y1prim / ry
	var cyprim = -c * ry * x1prim / rx

	var center = Vector2((cosr * cxprim - sinr * cyprim) + 
		((start.x + end.x) / 2),
		(sinr * cxprim + cosr * cyprim) + 
		((start.y + end.y) / 2))

	var ux = (x1prim - cxprim) / rx
	var uy = (y1prim - cyprim) / ry
	var vx = (-x1prim - cxprim) / rx
	var vy = (-y1prim - cyprim) / ry
	var n = sqrt(ux * ux + uy * uy)
	var p = ux
	
	# https://svn.apache.org/repos/asf/xmlgraphics/batik/branches/svg11/sources/org/apache/batik/ext/awt/geom/ExtendedGeneralPath.java
	var theta = acos(p / n)
	if uy < 0:
		theta = -theta

	n = sqrt((ux * ux + uy * uy) * (vx * vx + vy * vy))
	p = ux * vx + uy * vy
	var delta = acos(0) if p == 0 else acos(p / n)
	if (ux * vy - uy * vx) < 0:
		delta = -delta
	if not sweep and delta > 0:
		delta -= TAU
	elif sweep and delta < 0:
		delta += TAU
	var params = ReturnArc.new()
	params.theta = fmod(theta, TAU)
	params.delta = fmod(delta, TAU)
	params.center = center
	params.radius = Vector2(rx, ry)
	return params


func elliptic_arc_point(c: Vector2, r: Vector2, x_angle: float, t: float) -> Vector2:
	return Vector2(
		c.x + r.x * cos(x_angle) * cos(t) - r.y * sin(x_angle) * sin(t),
		c.y + r.x * sin(x_angle) * cos(t) + r.y * cos(x_angle) * sin(t))
