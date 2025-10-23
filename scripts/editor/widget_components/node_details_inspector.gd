extends InspectorChildBase

class_name NodeDetailsInspector

"""
This acts as a container for the properties of a selected node within the current graph.
"""

## SIGNALS

## this is emitted when a item in the list is selected, and passes the data of the selected item.
signal item_selected(key : Variant, data : Variant)
signal add_property(active_node : Node)

@onready var _property_list : ItemList = $VBoxContainer/PropertyList_SC/PropertyList
@onready var _add_property_button : Button = $VBoxContainer/HBoxContainer/Buttons/AddPropertyButton

var _active_node : BaseStoryNode

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
	_add_property_button.disabled = true

func _on_graph_node_selected(node: Node) -> void:
	_active_node = node
	set_node_properties(node.get_story_data_key())
	_add_property_button.disabled = false

func on_list_item_selected(index: int) -> void:
	var item = _property_list.get_item_text(index)
	item_selected.emit(item, _active_node.get_story_data())

func _on_add_property_button_pressed() -> void:
	add_property.emit(_active_node)
