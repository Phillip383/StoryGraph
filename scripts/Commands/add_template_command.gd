extends Command
class_name AddTemplateCommand

##@class
##This command add's a template to a selected node. Templates are added to node's via their template component and not stored directly in their story data dictionary. This make's it easier to manage edit's to templates, and the update to the node's that reference it.

var _node : BaseStoryNode
var _template : Dictionary
var _template_name : String
##@param - node: The node that the template should be added too.
##@param - file_path: The absolute path to the template file to add.
func _init(node : BaseStoryNode) -> void:
	var file_path = "" ## TODO: Spawn a window to select the template, get it's file path from there.
	_node = node
	_template = JSON.parse_string(FileAccess.get_file_as_string(file_path))
	_template_name = file_path.substr(file_path.rfind("/") + 1).get_slice(".", 0)

func execute() -> void:
	_add_template()

func _add_template() -> void:
	_node.get_template_component().add_template(_template_name, _template)
