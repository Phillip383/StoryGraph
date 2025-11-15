extends GraphNode

class_name BaseStoryNode


### The base graph node for the story graphing system. ###

## SIGNALS
signal on_data_changed(data) ## Emitted when a property is added, removed, or it's value is updated. Useful to inform the editor of unsaved work.

@export_category("Story Data")
@export var story_data : Dictionary


@export_category("Node Data")
@export var node_data : NodeData ## Helpful data for saving the node and keeping track of their id's, it is unique per node, any default values will be erased at runtime.

## SAVE/LOAD KEYS
const ID : StringName = "id"
const NAME : StringName = "name"
const TYPE : StringName = "type"
const POSITION : StringName = "pos"
const DATA : StringName = "data"
const PRERQUISITES : StringName = "prerequisites" ## TODO: Make this settable from the project settings.
const TEMPLATES : StringName = "templates"

## SLOT COLORS
const LINK_COLOR : Color = Color.YELLOW
const UNI_COLOR : Color = Color.DARK_SALMON ## The node can accept input's from any node, except LINK.
const EXIT_COLOR : Color = Color.DARK_RED ## Can accepts from Entry and Transit, not LINK

##PRIVATE MEMBERS
## This component house's the functionality for adding/removing/updating templates on the node.
@onready var _template_comp : TemplateComponent = TemplateComponent.new()

func _ready() -> void:
	node_data = NodeData.new()
	_template_comp.template_added.connect(func(template) : on_data_changed.emit(template))

## Set's the valid connection types and active slots based on the NodeType enum. The addtional allowed connection types are added in level.gd, as the graph handles the connections.
func _set_slots_by_type():
	var type = node_data.node_type
	var input_enable = true
	var output_enable = false
	var left_idx = 0
	var right_idx = 1
	if type == node_data.NodeType.ENTRY: ## Entry can output to EXIT and TRANSIT
		set_slot(left_idx, input_enable, NodeData.NodeType.LINK, LINK_COLOR, output_enable, 0, UNI_COLOR)
		set_slot(right_idx, !input_enable, 0, LINK_COLOR, !output_enable, NodeData.NodeType.ENTRY, UNI_COLOR)
	elif type == node_data.NodeType.EXIT:
		## Disable Right Slot
		set_slot(left_idx, input_enable, NodeData.NodeType.EXIT, EXIT_COLOR, output_enable, 0, UNI_COLOR)
		set_slot(right_idx, !input_enable, 0, LINK_COLOR, output_enable, 0, LINK_COLOR)
	elif type == node_data.NodeType.LINK: ## Link's can only be connected to Entry and Transit.
		## Disable left slot
		set_slot(left_idx, !input_enable, 0, LINK_COLOR, output_enable, 0, LINK_COLOR)
		set_slot(right_idx, !input_enable, 0, LINK_COLOR, !output_enable, NodeData.NodeType.LINK, LINK_COLOR)
	else:
		## Enable both slots with the UNI_COLOR for transit nodes.
		set_slot(left_idx, input_enable, NodeData.NodeType.TRANSIT, UNI_COLOR, output_enable, 0, UNI_COLOR)
		set_slot(right_idx, !input_enable, 0, UNI_COLOR, !output_enable, NodeData.NodeType.EXIT, UNI_COLOR)


## Node data is for loading and saving projects
func get_node_data() -> NodeData:
	return node_data


func get_node_type() -> NodeData.NodeType:
	return node_data.node_type


func get_node_id() -> int:
	return node_data.node_id


func set_node_id(id : int) -> void:
	node_data.node_id = id


func get_template_component() -> TemplateComponent:
	return _template_comp


## @return story_data: the properties currently on this node.
func get_story_data() -> Dictionary:
	return story_data


## @return story_data keys: returns the keys of the properties on this node.
func get_story_data_key() -> Array:
	return story_data.keys()


## @return: returns true if a property already exists and false otherwise.
func does_property_exist(key : StringName) -> bool:
	return true if story_data.get(key) else false


##Add's a new property to the node.
#@param key: the property name.
#@param data: the property data.
#@emit: on_data_changed
func add_data(key : StringName, data : Variant) -> void:
	story_data.get_or_add(key, data)
	on_data_changed.emit(story_data)


##Set's an existing property on this node.
#@param key: the property to set.
#@param data: the incoming data.
#@emit: on_data_changed
func set_existing_data(key : StringName, data : Variant) -> void:
	story_data[key] = data
	on_data_changed.emit(story_data)


##Removes a property from the node.
#@param key: The property to remove.
#@emit: on_data_changed
func remove_data(key : StringName) -> void:
	story_data.erase(key)
	on_data_changed.emit(story_data)


##Sets the node's name.
#@param _title: The name for the node.
func set_node_title(_title : StringName) -> void:
	title = _title

func set_node_type(_type : NodeData.NodeType):
	node_data.node_type = _type

## Packs the node's state into a dictionary and returns it.
# @return _state: the keys of the dictionary in the order they are created is:
#	name, - The title of the node.
#	id, - The id of the node.
#	type, -  The type for the node.
#	pos, - The position of the node within the graph
#	data - The properties of the node.
func save_node() -> Dictionary:
	var _state = {}
	_state[NAME] = title
	_state[ID] = node_data.node_id
	_state[TYPE] = node_data.node_type
	_state[POSITION] = position_offset
	_state[DATA] = story_data
	_state[TEMPLATES] = get_template_component().get_templates()
	return _state

## Loads a nodes previous state
#@param _state : Keys of the _state dictionary are:
#	name, the title of the node
#	id, the id of the node within it's parent graph
#	type, the type of node it is IE, entry, transit, end
#	pos, the position of the node within it's parent graph.
#	data - the properties that were added to this node.
func load_node(_state) -> void:
	title = _state[NAME]
	node_data.node_id = _state[ID] as int
	node_data.node_type = _state[TYPE] as int
	position_offset = parse_position( _state[POSITION])
	story_data = _state[DATA]
	var templates = _state.get_or_add(TEMPLATES, {})
	get_template_component().set_templates(templates)
	_set_slots_by_type()

func parse_position(pos : String) -> Vector2:
	pos = pos.trim_prefix("(")
	pos = pos.trim_suffix(")")
	var pos_parts : Array = pos.split(",")
	return Vector2(pos_parts[0] as float, pos_parts[1] as float)
