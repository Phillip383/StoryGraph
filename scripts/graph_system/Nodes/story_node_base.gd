extends GraphNode

class_name BaseStoryNode

"""
The base graph node for the story graphing system.
"""
## SIGNALS
signal on_data_changed(data) ## Emitted when a property is added, removed, or it's value is updated. Useful to inform the editor of unsaved work.

@export_category("Story Data")
@export var story_data : Dictionary[StringName, Variant]

@export_category("Node Data")
@export var node_data : NodeData ## Helpful data for saving the node and keeping track of their id's, it is unique per node, any default values will be erased at runtime.

func _ready() -> void:
	node_data = NodeData.new()

## Node data is for loading and saving projects
func get_node_data():
	return node_data

## @return story_data: the properties currently on this node.
func get_story_data() -> Dictionary[StringName, Variant]:
	return story_data

## @return story_data keys: returns the keys of the properties on this node.
func get_story_data_key() -> Array[StringName]:
	return story_data.keys()

## @return: returns true if a property already exists and false otherwise.
func does_property_exist(key : StringName) -> bool:
	return true if story_data.get(key) else false

"""
Add's a new property to the node.
@param key: the property name.
@param data: the property data.
@emit: on_data_changed
"""
func add_data(key : StringName, data : Variant):
	story_data.get_or_add(key, data)
	on_data_changed.emit(story_data)

"""
Set's an existing property on this node.
@param key: the property to set.
@param data: the incoming data.
@emit: on_data_changed
"""
func set_existing_data(key : StringName, data : Variant):
	story_data[key] = data
	on_data_changed.emit(story_data)

"""
Removes a property from the node.
@param key: The property to remove.
@emit: on_data_changed
"""
func remove_data(key : StringName):
	story_data.erase(key)
	on_data_changed.emit(story_data)

"""
Sets the node's name.
@param _title: The name for the node.
"""
func set_node_title(_title : StringName):
	#TODO: Allow for renaming of node's and emit a new signal to inform of the change.
	title = _title

"""
Packs the node's state into a dictionary and returns it.
@return _state: the keys of the dictionary in the order they are created is:
	name, - The title of the node.
	id, - The id of the node.
	type, -  The type for the node.
	pos, - The position of the node within the graph
	data - The properties of the node.
"""
func save_node():
	var _state = {}
	_state["name"] = title
	_state["id"] = node_data.node_id
	_state["type"] = node_data.node_type
	_state["pos"] = position_offset
	_state["data"] = story_data
	return _state

"""
Loads a nodes previous state
@param _state : Keys of the _state dictionary are:
	name, the title of the node
	id, the id of the node within it's parent graph
	type, the type of node it is IE, entry, transit, end
	pos, the position of the node within it's parent graph.
	data - the properites that were added to this node.
"""
func load_node(_state : Dictionary[StringName, Variant]):
	title = _state["name"]
	node_data.node_id = _state["id"]
	node_data.node_type = _state["type"]
	position_offset = _state["pos"]
	story_data = _state["data"]

"""
Packs the node into a dictionary format of {name : data}
@return {name : data}
"""
func export_node():
	return {title : story_data}
