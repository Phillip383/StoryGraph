extends MarginContainer

class_name NodeDetailsInspector

"""
This acts as a container for the properties of a selected node within the current graph.
"""

@onready var _property_list : ItemList = $VBoxContainer/PropertyList_SC/PropertyList 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
This method is called by the parent node InspectorContainer when the container receives a request to change.
"""
func on_change_request(context : Variant):
	print(self, " Context of event: ", context)

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