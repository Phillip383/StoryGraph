extends InspectorChildBase

class_name LevelInspector

@onready var tree : Tree = $VBoxContainer/Tree


var root_item : TreeItem
var active_level : Level
var story_lines : Dictionary[String, Node] ## Stored as a dictionary for fast lookup when a node is clicked in the tree to move graph view to focus that node.

var tree_items : Dictionary[String, TreeItem]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	tree.item_selected.connect(focus_selected_story_line)
	FileManager.post_level_load.connect(_on_level_load)
	FileManager.level_renamed.connect(_on_level_renamed)

## Creates the tree structure with the active level's nodes.
func create_tree() -> void:
	tree.clear()
	story_lines.clear()

	root_item = tree.create_item()
	if active_level:
		find_level_story_lines()
		root_item.set_text(0, active_level.name)
		for story in story_lines:
			var line : TreeItem = root_item.create_child()
			line.set_text(0, story)
			tree_items[story] = line


func find_level_story_lines() -> void:
	# For every entry node create a item in the tree.
	for child in active_level.get_children():
		var node : BaseStoryNode = child as BaseStoryNode
		if node and node.get_node_type() == NodeData.NodeType.ENTRY:
			story_lines.get_or_add(node.title, node)

## Called when a level, story line, or a node is added or deleted from the project. Takes the parent node and add's the item to the tree. This structure will be more performant than iterating over the entire level or graph looking for a change.
func update_tree(_parent : Node, _item : Variant) -> void:
	pass

func _on_level_renamed(_old : StringName, _new : StringName):
	## If it's the active level, rename the root.
	if root_item and root_item.get_text(0) == _old:
		root_item.set_text(0, _new)

func _on_level_changed(level: Level) -> void:
	if active_level == level:
		return

	active_level = level
	create_tree()


func _on_level_save(_active_level: Level) -> void:
	if _active_level != active_level: ## Protect against save all.
		return

	active_level = _active_level
	create_tree()

func _on_level_load(level : Level) -> void:
	active_level = level
	create_tree()


func on_story_line_added(node: BaseStoryNode) -> void:
	story_lines[node.title] = node
	var line : TreeItem = root_item.create_child()
	line.set_text(0, node.title)
	tree_items[node.title] = line


func on_story_lines_removed(_names: Array[StringName]) -> void:
	for node_name in _names:
		root_item.remove_child(tree_items[node_name])

func focus_selected_story_line() -> void:
	var _item_text : String = tree.get_selected().get_text(0)
	var level_center : Vector2 = active_level.size / 2.0
	var node : BaseStoryNode = story_lines[_item_text]
	active_level.scroll_offset = (node.position_offset * active_level.zoom) - level_center + (node.size / 2.0)
	active_level.zoom = 1.4
	active_level.set_selected(node)


func _on_search_text_changed(new_text: String) -> void:

	for item in root_item.get_children():
		if item.get_text(0).contains(new_text):
			item.visible = true
		else:
			item.visible = false

	if new_text.length() == 0:
		for item in root_item.get_children():
			item.visible = true
