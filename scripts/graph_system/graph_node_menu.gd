extends PopupMenu

@export var GraphNodeTypes : Array[PackedScene]

var ADD_NODE_ID := 0

## SIGNALS
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
