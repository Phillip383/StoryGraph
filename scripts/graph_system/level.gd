extends GraphEdit

class_name Level

const NODE_SCENE = preload("res://scenes/UI/Graph/Nodes/story_node_base.tscn")

const DEFAULT_NAME = "(unsaved)*"
## EXPORTS
@export var level_data : LevelData ## This is handled internally, no need to change values in the editor, it's export for debugging purposes, and is unique per level instance.

## SIGNALS
signal on_changed() ## A signal that will emit when any change occurs to the graph, this can be used to tell the user they have unsaved work.
signal level_name_change(level : Level)


@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tab_name(DEFAULT_NAME)
	level_data = LevelData.new()
	popup_request.connect(_on_popup_request)
	connection_request.connect(_on_connection)

func set_tab_name(level_name : String):
	name = level_name
	level_name_change.emit(self)

"""returns the LevelData resource for this level."""
func get_level_data():
	return level_data

"""
Listens for the popup request of the graph. Used primarily to make the context menu visible at the mouse location
"""
func _on_popup_request(_location : Vector2):
	var clicked_node : BaseStoryNode = get_node_at_position(_location)
	if is_instance_valid(clicked_node):
		print(clicked_node)
	else:
		context_menu.position = get_viewport().get_mouse_position()
		context_menu.show()

"""
Listens for the add node request from the context menu.
"""
func add_node(node : GraphNode):
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	add_child(node)
	on_changed.emit()

"""
Listens for the connection request of the graph.
"""
func _on_connection(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)
	on_changed.emit()

"""
This methods intended functionality is to check if the user right clicks on a node to keep the graph from consuming the input for it's context menu signal.
"""
func get_node_at_position(_location: Vector2):
	for child in get_children():
		if child is BaseStoryNode: ## Check if the child is a story node.
			var node = child as BaseStoryNode
			var click_pos = ((_location + scroll_offset) / zoom) - node.position_offset
			if Rect2(Vector2.ZERO, node.size).has_point(click_pos):
				return node
	return null

"""
packs the level connections and it's node's within a dictionary and save's it a .level file. The level_state dictionary structure:
	name, - The level name.
	id, - The level id
	con, - An array of dictionaries for the connections of the graph.
	nodes - An array of all the node's within the graph
@param _file_name: the name to give the saved level.
@return A dictionary of the level's packed state, or null if the save failed.
"""
func save_level(_file_name = name) -> Dictionary[StringName, Variant]:

	set_tab_name(_file_name) # Set the tab name in the levels_container to the file_name.

	var _state : Dictionary[StringName, Variant]
	_state["name"] = _file_name
	_state["id"] = level_data.level_id
	_state["con"] = connections
	_state["nodes"] = []

	for node in get_children():
		if node.is_in_group("Story Node"):
			_state["nodes"].append(node.save_node())

	return _state

"""
Loads a level's previous state from disk.
@param _file - the level file to load.
"""
func load_level(_data):
	name = _data["name"]
	level_data.level_id = _data["id"]
	level_data.level_name = name
	connections = _data["con"]
	var nodes = _data["nodes"]

	# Add the nodes	
	for node_data in nodes:
		var loaded_node : BaseStoryNode = NODE_SCENE.instantiate()
		loaded_node.load_node(node_data)
		add_child(loaded_node)

	## TODO: Add the connections
