extends GraphEdit

class_name StoryGraph

## SIGNALS
"""
When any change occurs this is emitted.
When the event is emitted a context array of the event is created and provided.
The context can contain anything, but the best is: [EventType, self : Node, InstigatingObject : Node, Description : String]
The object that emitted the signal as well as any target can be sent as well.
To connect the signal to all of the containers call the static GraphEditor.init_connections(Node) method in _ready, pass the node needing to be connected (self).
The method binds the signal to the change_children() method of the containers.
This was done so the application wouldn't have to search the scene tree for every child of the inspectors.
"""
signal on_changed(context : Array[Variant])

@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_request.connect(_on_popup_request)
	context_menu.connect("_on_add_node", _on_add_node)
	connection_request.connect(_on_connection)
	GraphEditor.init_connections(self) ## Setup on_changed signal with the various active inspectors.

"""
This method is called by the parent node InspectorContainer when the container receives a request to change.
"""
func on_change_request(context : Variant):
	print(self, "Context of event: ", context)

"""
Listens for the popup request of the graph. Used primarily to make the context menu visible at the mouse location
"""
func _on_popup_request(_location : Vector2):
	context_menu.position = get_viewport().get_mouse_position()
	context_menu.show()
	var context : Array[Variant] = [EventType.Type.UPDATE, self, context_menu, "Context Menu Open"]
	on_changed.emit(context) ## Emit for the popup request. ## TODO: Use this to change the state of the application eventually.

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
