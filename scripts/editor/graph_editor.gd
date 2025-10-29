extends CanvasLayer


## TODO: need to link to the signal for add_node or delete node and set the ID on the node, or decrement it here upon deletion.
var _node_id : int ## This will increment whenever a node is added or decrement on delete

## TODO: use this level id for levels, make it unique! A level can be a table, and the composite key between a unique level id and a unique node id will ensure the correct linking of nodes between levels. Increment this when a level is created, decrement when a level is deleted.
var _level_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.low_processor_usage_mode = true

func increment_node_id():
	_node_id += 1

func decrement_node_id():
	_node_id -= 1

func increment_level_id():
	_level_id += 1

func decrement_level_id():
	_level_id -= 1
