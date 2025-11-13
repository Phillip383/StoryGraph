extends InspectorChildBase
class_name PropertyEditorControl

var _active_node : BaseStoryNode
@onready var _strat_context : StrategyContext = StrategyContext.new()
@onready var _editor_container : PanelContainer = $Value_Editor_C

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_property_selected(property_name : String, node : BaseStoryNode):
	var type = node.get_node_type()
	var strat : Strategy
	if type == NodeData.NodeType.LINK:
		strat = EditLinkStrat.new(_editor_container, node)
	else:
		strat = UpdatePropertyStrat.new(_editor_container, node, property_name)

	_strat_context.set_strategy(strat).execute()


func _on_add_property_button_pressed(node : Node) -> void:
	var add_strat : AddPropertyStrat = AddPropertyStrat.new(_editor_container, node)
	_strat_context.set_strategy(add_strat).execute()

# Clears the previously edited properties when the level is changed.
func _on_level_changed(_level: Level) -> void:
	_strat_context.destroy()
	if _level and not _level.node_deselected.is_connected(_on_graph_node_deselected):
		_level.node_deselected.connect(_on_graph_node_deselected)

func _on_graph_node_deselected(_node):
	_strat_context.destroy()
