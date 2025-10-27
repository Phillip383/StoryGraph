extends GraphNode

class_name BaseStoryNode

"""
The base graph node for the story graphing system.
"""
## SIGNALS
signal on_data_changed(data) ## Emitted when a property is added, removed, or it's value is updated.

@export_category("Story Data")
@export var story_data : Dictionary[StringName, Variant]

## Helpful data for saving the node and keeping track of their id's
var node_data

func _ready() -> void:
	node_data = NodeData.new()
	on_data_changed.connect(on_value_changed)

## Node data is for loading and saving projects
func get_node_data():
	return node_data

func get_story_data() -> Dictionary[StringName, Variant]:
	return story_data

func get_story_data_key() -> Array[StringName]:
	return story_data.keys()

func add_data(key : StringName, data : Variant):
	story_data.get_or_add(key, data)
	on_data_changed.emit(story_data)

func set_existing_data(key : StringName, data : Variant):
	story_data[key] = data
	on_data_changed.emit(story_data)

func remove_data(key : StringName):
	story_data.erase(key)
	on_data_changed.emit(story_data)

## TODO: Flag a change prompting for a save.
func on_value_changed(data):
	pass