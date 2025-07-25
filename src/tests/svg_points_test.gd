# GdUnit generated TestSuite
class_name SvgPointsTest
extends GdUnitTestSuite
@warning_ignore('unused_parameter')
@warning_ignore('return_value_discarded')

# TestSuite generated from
const __source = 'res://tools/svg_points.gd'


func test_parse_num() -> void:
	var svg = SVGPoints.new()
	var token_str = "24"
	var result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(2)
	assert_float(result.num).is_equal_approx(24.0, 0.0001)
	
	token_str = "-24"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(3)
	assert_float(result.num).is_equal_approx(-24.0, 0.0001)
	
	token_str = "0.3"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(3)
	assert_float(result.num).is_equal_approx(0.3, 0.0001)
	
	token_str = ".3"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(2)
	assert_float(result.num).is_equal_approx(0.3, 0.0001)
	
	token_str = "56.367"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(6)
	assert_float(result.num).is_equal_approx(56.367, 0.0001)
	
	token_str = "-96.367"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(7)
	assert_float(result.num).is_equal_approx(-96.367, 0.0001)
	
	token_str = "11e2"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(4)
	assert_float(result.num).is_equal_approx(1100, 0.0001)
	
	token_str = "-1e-1"
	result = svg.parse_num(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(5)
	assert_float(result.num).is_equal_approx(-0.1, 0.0001)


func test_get_coor() -> void:
	var svg = SVGPoints.new()
	var token_str = "8,6"
	var result = svg.get_coor(token_str, 0)
	assert_bool(result.error).is_equal(false)
	assert_int(result.idx).is_equal(3)
	assert_vector(result.coor).is_equal(Vector2(8,6))
