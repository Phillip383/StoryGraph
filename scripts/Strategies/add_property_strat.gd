extends Strategy
class_name AddPropertyStrat

@export_file var ADD_PROPERTY_EDITOR = "res://scenes/Property_Editor/Add_Property/add_node_property_widget.tscn"

signal property_added(node)

var _parent
var _node
var _editor : PropertyEditor

func _init(parent_container : Container, node : BaseStoryNode) -> void:
	_parent = parent_container
	_node = node

func execute() -> void:
	_editor = load(ADD_PROPERTY_EDITOR).instantiate()
	_parent.add_child(_editor)
	_editor.set_active_node(_node)
	_editor.property_added.connect(func(node) : property_added.emit(node))

func destroy() -> void:
	if _editor:
		_editor.queue_free()
