extends GraphNode

class_name BaseStoryNode

"""
The base graph node for the story graphing system.

"""

@export_category("Story Data")
@export var story_data : StoryData
@export var node_data : NodeData

## SIGNALS
signal on_data_changed(data) ## Emitted when a property is added, removed, or it's value is updated.

## Node data is for loading and saving projects
func get_node_data():
	return node_data

func get_story_data():
	return story_data