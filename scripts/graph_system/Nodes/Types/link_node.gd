extends BaseStoryNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	node_data.node_type = node_data.NodeType.LINK


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
