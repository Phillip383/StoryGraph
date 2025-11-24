extends Command
class_name AddTemplateCommand

##@class
##This command add's a template to a selected node. Templates are added to node's via their template component and not stored directly in their story data dictionary. This make's it easier to manage edit's to templates, and the update to the node's that reference it.

signal template_added()

var _node : BaseStoryNode
var _template : Dictionary
var _template_name : String
var _remove : bool
var _level : Level

##@param - node: The node that the template should be added too.
##@param - file_path: The absolute path to the template file to add.
##@param - level - The level the node resides in, this is used for template references.
##@param - remove_node_data - default false, when true, it will clear the properties on the node.
func _init(node : BaseStoryNode, template_path : String, level : Level, remove_node_data : bool = false) -> void:
	_node = node
	_level = level
	_template = JSON.parse_string(FileAccess.get_file_as_string(template_path))
	_template_name = template_path.get_file().get_slice(".", 0)
	_remove = remove_node_data

func execute() -> void:
	_add_template()

func _add_template() -> void:
	_node.get_template_component().add_template(_template_name, _template)
	var ref_id : String = "%d-%d" % [_level.get_level_id(), _node.get_node_id()]
	GraphEditor.add_template_node_ref(_template_name, ref_id)
	if _remove:
		_node.clear_story_data()
	template_added.emit()
