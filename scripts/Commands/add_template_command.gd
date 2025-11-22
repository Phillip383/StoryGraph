extends Command
class_name AddTemplateCommand

##@class
##This command add's a template to a selected node. Templates are added to node's via their template component and not stored directly in their story data dictionary. This make's it easier to manage edit's to templates, and the update to the node's that reference it.

signal template_added()

var _node : BaseStoryNode
var _template : Dictionary
var _template_name : String
var _remove : bool
##@param - node: The node that the template should be added too.
##@param - file_path: The absolute path to the template file to add.
func _init(node : BaseStoryNode, template_path : String, remove_node_data : bool = false) -> void:
	_node = node
	_template = JSON.parse_string(FileAccess.get_file_as_string(template_path))
	_template_name = template_path.get_file().get_slice(".", 0)
	_remove = remove_node_data

func execute() -> void:
	_add_template()

func _add_template() -> void:
	_node.get_template_component().add_template(_template_name, _template)
	GraphEditor.add_template_node_ref(_template_name, _node.get_node_id())
	if _remove:
		_node.clear_story_data()
	template_added.emit()
