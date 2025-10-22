extends CanvasLayer

var inspectors : Array[Node]
var _nodeID : int ## This will increment whenever a node is added or decrement on delete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.low_processor_usage_mode = true
	inspectors = get_tree().get_nodes_in_group("Inspectors")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func increment_node_id():
	_nodeID += 1

func decrement_node_id():
	_nodeID -= 1
