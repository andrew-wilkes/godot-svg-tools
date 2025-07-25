class_name Helpers

extends Object

static func get_xml_nodes(file_path: String) -> Dictionary:
	var parser: XMLParser = XMLParser.new()
	var results: Dictionary
	parser.open(file_path)
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			var node_name = parser.get_node_name()
			var attributes_dict = {}
			for idx in range(parser.get_attribute_count()):
				attributes_dict[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
			if results.has(node_name):
				results[node_name].append(attributes_dict)
			else:
				results[node_name] = [attributes_dict]
	return results
