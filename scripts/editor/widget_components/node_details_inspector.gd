extends InspectorChildBase

class_name NodeDetailsInspector

"""
This acts as a container for the properties of a selected node within the current graph.
"""

@onready var _property_list : ItemList = $VBoxContainer/PropertyList_SC/PropertyList 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
Returns the current list of node properties currently held in this widget.
"""
func get_node_properties() -> Array[Node]:
	return _property_list.get_children()

"""
Adds the selected nodes properties in the current graph to this widget.
The method clears the current properties before adding the new properties.
"""
func set_node_properties(property_names : Array[StringName]):
	clear_node_properties()
	for property in property_names:
		_property_list.add_item(property)

func clear_node_properties():
	_property_list.clear()


func _on_graph_node_deselected(_node: Node) -> void:
	clear_node_properties()

func _on_graph_node_selected(node: Node) -> void:
	set_node_properties(node.get_story_data_key())
