extends PopupMenu

class_name StoryGraphContextMenu

"""
The responsibilities of this class is to add nodes of various types to the graph as well as other options that might be added in time.
"""

"""
The types of graph nodes that can be added to the graph
"""
@export var GraphNodeTypes : Array[PackedScene]

"""
The id for the Add node option. These option will probably be moved to an enum at a later time and the items be generated on func _ready
instead of via the editor.
"""
var ADD_NODE_ID := 0

## SIGNALS
"""
Emitted when a request is received to add a node to the current graph.
@param node - the node being added to the graph.
"""
signal _on_add_node(node : GraphNode)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id_pressed.connect(_on_selection)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_selection(id : int):
	match id:
		ADD_NODE_ID:
			var new_node = GraphNodeTypes[0].instantiate() as GraphElement
			_on_add_node.emit(new_node)
