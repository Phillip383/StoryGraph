extends GraphEdit

class_name Level

@export var NODE_SCENE : PackedScene
const DEFAULT_NAME = "(unsaved)"

## EXPORTS
@export var _node_id : int ## DO NOT CHANGE THIS WITHOUT THE METHODS!!!!

## SIGNALS
signal on_edited(level : Level) ## A signal that will emit when any change occurs to the graph, this can be used to tell the user they have unsaved work.

signal on_story_line_added(node : BaseStoryNode)
signal on_story_lines_removed(_name : Array[StringName])

## Keys for the saving and loading dictionary.
const NAME = "name"
const ID = "id"
const NODE_ID = "node_id"
const CONNECTIONS = "con"
const NODES = "nodes"


@onready var context_menu = $"GraphNodeMenu"
@onready var manager = $GraphManager ## Handles the state of the level.

var node_details : NodeDetailsInspector

var node_connections : Array

var level_id : int = -1
var _resource_path : String

func _ready() -> void:
	name = DEFAULT_NAME
	popup_request.connect(_on_popup_request)
	connection_request.connect(_on_connection)
	node_deselected.connect(on_node_deselected)
	node_selected.connect(on_node_selected)
	begin_node_move.connect(on_node_begin_move)
	delete_nodes_request.connect(delete_nodes)
	## Add the additional valid connection types.
	_init_connection_types()
	## Have to do this in _ready for every graph spawned, signals connected in the editor, are unique.
	node_details = get_tree().get_first_node_in_group("Node Details")

func get_next_node_id():
	_node_id += 1
	return _node_id

func get_current_state() -> GraphManager.GraphState:
	return manager.current_state

func get_resource_path() -> String:
	return _resource_path

func set_resource_path(path : String):
	_resource_path = path

func _init_connection_types():
	add_valid_connection_type(NodeData.NodeType.ENTRY, NodeData.NodeType.EXIT)
	add_valid_connection_type(NodeData.NodeType.ENTRY, NodeData.NodeType.TRANSIT)
	add_valid_connection_type(NodeData.NodeType.LINK, NodeData.NodeType.TRANSIT)
	add_valid_connection_type(NodeData.NodeType.TRANSIT, NodeData.NodeType.EXIT)


##Listens for the popup request of the graph. Used primarily to make the context menu visible at the mouse location
func _on_popup_request(_location : Vector2):
	var clicked_node : BaseStoryNode = get_node_at_position(_location)
	if is_instance_valid(clicked_node):
		print(clicked_node) ## TODO: Add node rename.
	else:
		context_menu.position = get_viewport().get_mouse_position()
		context_menu.show()


##Listens for the add node request from the context menu.
func add_node(node : GraphNode, _type : NodeData.NodeType = 0):
	add_child(node)
	node.on_data_changed.connect(on_node_changed)
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	node.set_node_id(get_next_node_id())
	node.set_node_type(_type)
	node._set_slots_by_type()
	manager._change_state(GraphManager.GraphState.EDITING)
	if node.get_node_type() == NodeData.NodeType.ENTRY:
		on_story_line_added.emit(node) ## Tell the tree and other elements a story line was added.
	on_edited.emit(self)

func delete_nodes(nodes : Array[StringName]):
	var story_lines : Array[StringName] = []
	for node_name in nodes:
		var node = get_node("%s" % node_name)
		if node.node_data.node_type == NodeData.NodeType.ENTRY:
			story_lines.append(node.title)
		## remove the connections to the deleted node
		node_connections = node_connections.filter( func(p) : return p["from_node"] != node.title and p["to_node"] != node.title)
		node.queue_free()

	if story_lines.size() > 0:
		on_story_lines_removed.emit(story_lines) ##Inform the tree and editor of the deleted nodes.

##Listens for the connection request of the graph.
func _on_connection(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	## Get the node's being connected names
	var f_node = get_node("%s" % from_node).title
	var t_node = get_node("%s" % to_node).title

	## Save the connections by node title, not instance name..
	node_connections.append({
		"from_node" : f_node,
		"from_port": from_port,
		"to_node" : t_node,
		"to_port" : to_port
	})

	connect_node(from_node, from_port, to_node, to_port)
	manager._change_state(GraphManager.GraphState.EDITING)
	on_edited.emit(self)

##This methods intended functionality is to check if the user right clicks on a node to keep the graph from consuming the input for it's context menu signal.
func get_node_at_position(_location: Vector2):
	for child in get_children():
		if child is BaseStoryNode: ## Check if the child is a story node.
			var node = child as BaseStoryNode
			var click_pos = ((_location + scroll_offset) / zoom) - node.position_offset
			if Rect2(Vector2.ZERO, node.size).has_point(click_pos):
				return node
	return null


##packs the level connections and it's node's within a dictionary and save's it a .level file. The level_state dictionary structure:
##	name, - The level name.
##	id, - The level id
##	con, - An array of dictionaries for the connections of the graph.
##	nodes - An array of all the node's within the graph
##@param _file_name: the name to give the saved level.
##@return A dictionary of the level's packed state, or null if the save failed.
func save(_file_name = name) -> Dictionary[StringName, Variant]:
	manager._change_state(GraphManager.GraphState.SAVING)
	name = _file_name
	var _state : Dictionary[StringName, Variant]
	_state[NAME] = _file_name
	_state[ID] = level_id
	_state[NODE_ID] = _node_id if _node_id else -1
	_state[CONNECTIONS] = node_connections
	_state[NODES] = []

	for node in get_children():
		if node.is_in_group("Story Node"):
			_state[NODES].append(node.save_node())

	manager._change_state(GraphManager.GraphState.IDLE)
	return _state


##Loads a level's previous state from disk.
##@param _file - the level file to load.
func load_level(_data):
	manager._change_state(GraphManager.GraphState.LOADING)
	name = _data[NAME]
	level_id = _data[ID]
	_node_id = _data[NODE_ID] if _data.get("node_id") else -1
	node_connections = _data[CONNECTIONS] if _data[CONNECTIONS] else []
	var nodes = _data[NODES]

	## Maps node's title to their new instance name.
	var node_map : Dictionary[String, String]
	# Add the nodes
	for node_data in nodes:
		var loaded_node : BaseStoryNode = NODE_SCENE.instantiate()
		add_child(loaded_node)
		loaded_node.load_node(node_data)
		node_map.get_or_add(loaded_node.title, loaded_node.name)
		loaded_node.on_data_changed.connect(on_node_changed) ## Need to reconnect to the signal for updates to the node.

	## Add the connections, using the nodes titles
	if node_connections:
		for connection in node_connections:
			connect_node(node_map[connection["from_node"]], connection["from_port"], node_map[connection["to_node"]], connection["to_port"])

	manager._change_state(GraphManager.GraphState.IDLE)

func on_node_changed(_data):
	manager._change_state(GraphManager.GraphState.EDITING)
	on_edited.emit(self)

func on_node_begin_move():
	manager._change_state(GraphManager.GraphState.EDITING)
	on_edited.emit(self)

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
