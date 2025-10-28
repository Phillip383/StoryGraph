extends PopupMenu


"""
The responsibilities of this class is to add nodes of various types to the graph as well as other options that might be added in time.
"""

"""
The id for the Add node option. These option will probably be moved to an enum at a later time and the items be generated on func _ready
instead of via the editor.
"""
var ADD_NODE_ID := 0

const NEW_NODE_MENU = preload("res://scenes/UI/Graph/Nodes/new_node.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id_pressed.connect(_on_selection)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_selection(id : int):
	match id:
		ADD_NODE_ID:
			var menu = NEW_NODE_MENU.instantiate()
			menu.position = position - menu.size / 2
			get_parent().add_child(menu)
