extends Resource

class_name NodeData

enum NodeType {
	ENTRY = 1, # The main node of a story line, and doesn't have an Input
	TRANSIT = 2, # Any intermediate nodes
	LINK = 3, # Links nodes of different graphs, making prerequisite mapping easier.
	EXIT = 4 # An exit node, doesn't have an Output.
}

## INTERNAL
@export_category("internal data") ## Data here is used for internal purposes such as saving and loading projects and exporting data
@export var node_id : int ## Works as a global incremental id for nodes, and will set the quest_id to the node_id upon exporting.
@export var node_type : NodeType = NodeType.ENTRY
@export var graph_position : Vector2
