extends GraphEdit

class_name Level

const SAVE_NEW_WINDOW = preload("res://scenes/UI/Popups/save_window.tscn")
const SAVE_WINDOW_TITLE = "Save Level"

const DEFAULT_NAME = "(unsaved)*"
## EXPORTS
@export var tab_name : StringName = DEFAULT_NAME ## Use the file name when saved, default to "unsaved"
@export var level_data : LevelData ## This is handled internally, no need to change values in the editor, it's export for debugging purposes, and is unique per level instance.

## SIGNALS
signal on_changed() ## A signal that will emit when any change occurs to the graph, this can be used to tell the user they have unsaved work.
signal level_name_change(level_name : String)


@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tab_name(DEFAULT_NAME)
	level_data = LevelData.new()
	popup_request.connect(_on_popup_request)
	connection_request.connect(_on_connection)

"""returns the tab_name, which also acts as it's file name."""
func get_tab_name():
	return tab_name

func set_tab_name(level_name : String):
	tab_name = level_name
	level_name_change.emit(level_name)

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

## A main/start/entry node represents the beginning of a storyline.
## Thus, we will loop through all the start nodes, getting their "from" connections and mapping their ID's as prerequisites, and then mapping their "to" connection as future quests in the storyline, that should unlock upon status change. 
## This data will be put in a dictionary and saved to disk in a .json file named {level_name}.json. The top level dictionary will be the name of the level, and the first entry will be it's level_id, thus "level_id" : {n}. After this, the level's nodes content will follow.
"""
Saves all the nodes, storylines, and their connections for this level
"""
func save_level(_file_name) -> Error:
	set_tab_name(_file_name)
	var levels_dir = GraphEditor.get_levels_directory()
	var file_path = "%s/%s.json" % [levels_dir, _file_name]
	var _file = FileAccess.open(file_path, FileAccess.WRITE)
	if _file:
		## TODO: do the saving
		pass
	else:
		##TODO: handle error
		pass
	_file.close()
	return OK

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_level"):
		## Prompt a save window to name the level if their is no name.
		if tab_name == DEFAULT_NAME:
			var save_window : SaveWindow = SAVE_NEW_WINDOW.instantiate()
			save_window.title = SAVE_WINDOW_TITLE
			add_child(save_window)
			save_window.on_save.connect(save_level)
		else:
			save_level(tab_name)
