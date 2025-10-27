extends GraphEdit

class_name StoryGraph

## EXPORTS
@export var tab_name : StringName = "(unsaved)*" ## Use the file name when saved, default to "unsaved"

@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_request.connect(_on_popup_request)
	context_menu.connect("_on_add_node", _on_add_node)
	connection_request.connect(_on_connection)

func get_tab_name():
	return tab_name

"""
Listens for the popup request of the graph. Used primarily to make the context menu visible at the mouse location
"""
func _on_popup_request(_location : Vector2):
	var clicked_node : BaseStoryNode = get_node_at_position(_location)
	if is_instance_valid(clicked_node):
		print(clicked_node)
	else:
		context_menu.position = get_viewport().get_mouse_position()
		context_menu.show()

"""
Listens for the add node request from the context menu.
"""
func _on_add_node(node : GraphNode):
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	add_child(node)

"""
Listens for the connection request of the graph.
"""
func _on_connection(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)

"""
This methods intended functionality is to check if the user right clicks on a node to keep the graph from consuming the input for it's context menu signal.
"""
func get_node_at_position(_location: Vector2):
	for child in get_children():
		if child is BaseStoryNode: ## Check if the child is a story node.
			var node = child as BaseStoryNode
			var click_pos = ((_location + scroll_offset) / zoom) - node.position_offset
			if Rect2(Vector2.ZERO, node.size).has_point(click_pos):
				return node
	return null