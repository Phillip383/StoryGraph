extends GraphEdit

class_name Level

const NODE_SCENE = preload("res://scenes/UI/Graph/Nodes/story_node_base.tscn")

const DEFAULT_NAME = "(unsaved)"
## EXPORTS
@export var level_data : LevelData ## This is handled internally, no need to change values in the editor, it's export for debugging purposes, and is unique per level instance.

var unsaved : bool = false

## SIGNALS
signal on_changed() ## A signal that will emit when any change occurs to the graph, this can be used to tell the user they have unsaved work.
signal level_name_change(level : Level)


@onready var context_menu = $"GraphNodeMenu"
@onready var manager = $GraphManager ## Handles the state of the level.

var node_details : NodeDetailsInspector

func _ready() -> void:
	name = DEFAULT_NAME
	level_data = LevelData.new()
	popup_request.connect(_on_popup_request)
	connection_request.connect(_on_connection)
	node_deselected.connect(on_node_deselected)
	node_selected.connect(on_node_selected)
	begin_node_move.connect(on_node_begin_move)

	## Have to do this in _ready for every graph spawned, signals connected in the editor, are unique.
	node_details = get_tree().get_first_node_in_group("Node Details")

func set_tab_name(level_name : String):
	name = level_name
	level_name_change.emit(self)

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
	node.on_data_changed.connect(on_node_changed)
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	add_child(node)
	manager._change_state(GraphManager.GraphState.EDITING)
	on_changed.emit()

"""
Listens for the connection request of the graph.
"""
func _on_connection(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)
	manager._change_state(GraphManager.GraphState.EDITING)
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
	manager._change_state(GraphManager.GraphState.SAVING)
	set_tab_name(_file_name) # Set the tab name in the levels_container to the file_name.

	var _state : Dictionary[StringName, Variant]
	_state["name"] = _file_name
	_state["id"] = level_data.level_id
	_state["con"] = connections
	_state["nodes"] = []

	for node in get_children():
		if node.is_in_group("Story Node"):
			_state["nodes"].append(node.save_node())

	manager._change_state(GraphManager.GraphState.IDLE)
	return _state

"""
Loads a level's previous state from disk.
@param _file - the level file to load.
"""
func load_level(_data):
	manager._change_state(GraphManager.GraphState.LOADING)
	set_tab_name(_data["name"])
	level_data.level_id = _data["id"]
	level_data.level_name = name
	connections = _data["con"]
	var nodes = _data["nodes"]

	# Add the nodes	
	for node_data in nodes:
		var loaded_node : BaseStoryNode = NODE_SCENE.instantiate()
		loaded_node.load_node(node_data)
		add_child(loaded_node)
		loaded_node.on_data_changed.connect(on_node_changed) ## Need to reconnect to the signal for updates to the node.
	## TODO: Add the connections
	for connection in connections:
		print(connections)
	
	manager._change_state(GraphManager.GraphState.IDLE)

func on_node_changed(_data):
	manager._change_state(GraphManager.GraphState.EDITING)
	on_changed.emit()

func on_node_begin_move():
	manager._change_state(GraphManager.GraphState.EDITING)
	on_changed.emit()

func on_node_selected(node : Node):
	node_details._on_graph_node_selected(node)

func on_node_deselected(node : Node):
	node_details._on_graph_node_deselected(node)

func on_level_changed(node : Node):
	if node == self:
		return
	else:
		manager._change_state(GraphManager.GraphState.IDLE)
		set_selected(null)
