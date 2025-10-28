extends InspectorChildBase

class_name LevelInspector


@onready var tree : Tree = $Tree

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func create_tree():
	pass

"""
Called when a level, story line, or a node is added or deleted from the project. Takes the parent node and add's the item to the tree. This structure will be more performant than iterating over the entire level or graph looking for a change.
"""
func update_tree(_parent : Node, _item : Variant):
	pass