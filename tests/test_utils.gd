extends GutUtils
class_name StaticTestUtils

## This class holds functions used across the tests to create various files and objects.

static var _levels: Array[Level] = []

##Path to a test's directory to hold created level's, it is deleted once the test's are completed.
const LEVEL_DIR = "/home/phillip/dev/projects/Godot/story-graph/tests/levels/"
static var _command_invoker: CommandInvoker


func _init() -> void:
	_command_invoker = CommandInvoker.new()
	DirAccess.make_dir_absolute(LEVEL_DIR)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		DirAccess.remove_absolute(LEVEL_DIR)

## Creates a level and returns it's path
static func create_level(_name: String) -> String:
	var path = LEVEL_DIR + _name
	return path

## Creates a dictionary object that represents a node's data and returns it.
##@param: type - The type of node to create.
##@param: data - The properties to give to the node.
##@param: templates - The templates to add to the node.
static func create_node(title: String, type: NodeData.NodeType, data: Dictionary, templates: Array[Dictionary]) -> BaseStoryNode:
	var new_node: BaseStoryNode = BaseStoryNode.new()

	new_node.set_node_type(type)
	new_node.set_node_title(title)
	new_node.story_data = data
	# Add the templates to the node.
	for template: Dictionary in templates:
		new_node.get_template_component().add_template(template.keys()[0], template.keys()[1])

	return new_node
