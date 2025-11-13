extends Strategy
class_name UpdatePropertyStrat

@export_file var _widget = "res://scenes/Property_Editor/Customize_Property/customize_property.tscn"

signal edit_confirmed()
signal edit_canceled()

var _parent
var _node
var _property_name
var _editor : CustomizeProperty

func _init(parent_container : Container, node : BaseStoryNode, property_name : String) -> void:
	_parent = parent_container
	_node = node
	_property_name = property_name

func execute() -> void:
	_editor = load(_widget).instantiate()
	_parent.add_child(_editor)
	_editor.populate_values(_property_name, _node)
	_editor.on_edit_confirmed.connect(func() : edit_confirmed.emit())
	_editor.on_edit_canceled.connect(func() : edit_canceled.emit())

func destroy() -> void:
	if _editor:
		_editor.queue_free()
