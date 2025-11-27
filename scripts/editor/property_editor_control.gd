extends InspectorChildBase
class_name PropertyEditorControl

@export_file var TEMPLATE_EDITOR = "res://scenes/Property_Editor/Customize_Property/customize_property.tscn"

signal property_added(node)
signal edit_canceled()

@onready var _strat_context : StrategyContext = StrategyContext.new()
@onready var _editor_container : PanelContainer = $Value_Editor_C

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

## Fills the property editor with the data for the template.
func template_open(temp_name : String, data : Dictionary):
	#TODO: Change this, as it won't allow for adding or removing properties.
	var editor = load(TEMPLATE_EDITOR).instantiate()
	_editor_container.add_child(editor)
	editor.populate_values(temp_name, data)


func _on_property_selected(property_name : String, node : BaseStoryNode):
	visible = true
	var type = node.get_node_type()
	var strat : Strategy
	if type == NodeData.NodeType.LINK:
		strat = EditLinkStrat.new(_editor_container, node)
	else:
		strat = UpdatePropertyStrat.new(_editor_container, node, property_name)
		strat.edit_canceled.connect(func() : edit_canceled.emit())

	_strat_context.set_strategy(strat).execute()


func _on_add_property_button_pressed(node : Node) -> void:
	visible = true
	var type = node.get_node_type()
	var strat : Strategy
	if type == NodeData.NodeType.LINK:
		strat = EditLinkStrat.new(_editor_container, node)
	else:
		strat = AddPropertyStrat.new(_editor_container, node)
		strat.property_added.connect(func(_node) : property_added.emit(_node))

	_strat_context.set_strategy(strat).execute()

# Clears the previously edited properties when the level is changed.
func _on_level_changed(_level: Level) -> void:
	_strat_context.destroy()
	if _level and not _level.node_deselected.is_connected(_on_graph_node_deselected):
		_level.node_deselected.connect(_on_graph_node_deselected)

func _on_graph_node_deselected(_node):
	_strat_context.destroy()
