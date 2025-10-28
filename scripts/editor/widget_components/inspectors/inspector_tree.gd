extends InspectorChildBase

class_name LevelInspector

@onready var tree : Tree = $Tree

var active_level : Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

"""
Creates the tree structure with the active level's nodes.
"""
func create_tree():
	tree.clear() ## Clean the tree before we create it...
	var root : TreeItem = tree.create_item()
	root.set_text(0, active_level.get_tab_name())

	## TODO: Fill the tree with the main node's, creating sub items for their connections.

"""
Called when a level, story line, or a node is added or deleted from the project. Takes the parent node and add's the item to the tree. This structure will be more performant than iterating over the entire level or graph looking for a change.
"""
func update_tree(_parent : Node, _item : Variant):
	pass

func _on_level_changed(level: Level) -> void:
	active_level = level
	create_tree()
