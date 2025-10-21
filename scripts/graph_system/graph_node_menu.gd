extends PopupMenu

@export var GraphNodeTypes : Array[PackedScene]

var ADD_NODE_ID := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	id_pressed.connect(_on_selection)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_selection(id : int):
	match id:
		ADD_NODE_ID:
			var graph = get_parent() as GraphEdit
			var new_node = GraphNodeTypes[0].instantiate() as GraphElement
			new_node.position_offset = Vector2i(graph.get_local_mouse_position()) - graph.context_menu_offset
			graph.add_child(new_node)
