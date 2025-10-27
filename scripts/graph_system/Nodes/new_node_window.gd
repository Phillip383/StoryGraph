extends Window

"""
The types of graph nodes that can be added to the graph
"""
@export var node_types : Dictionary[NodeData.NodeType, PackedScene]

var _selected_type : int
var _name : StringName

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(_on_cancel_pressed)
	pass # Replace with function body.

func _on_type_selected(ID : int) -> void:
	_selected_type = ID

func _on_cancel_pressed() -> void:
	queue_free()

## creates a node of selected type and names the node; add's it to the parent graph of the window. Destroys itself once done.
func _on_confirm_pressed() -> void:
	var new_node : BaseStoryNode = node_types[_selected_type].instantiate()
	new_node.set_node_title(_name)
	get_parent().add_node(new_node)
	queue_free()

## TODO: Check the graph for any node's with existing name, disable confirm button.
func _on_name_changed(new_text: String) -> void:
	_name = new_text
