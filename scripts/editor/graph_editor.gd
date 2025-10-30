extends CanvasLayer

## Const string literals for storing the state of the editor upon closing and opening.
const LAST_OPEN_PROJ_KEY = "last_open_project"

## TODO: Move this to the level class, as a level will be responsible for id'ing it's nodes. need to link to the signal for add_node or delete node and set the ID on the node, or decrement it here upon deletion.
var _node_id : int ## This will increment whenever a node is added or decrement on delete

## TODO: use this level id for levels, make it unique! A level can be a table, and the composite key between a unique level id and a unique node id will ensure the correct linking of nodes between levels. Increment this when a level is created, decrement when a level is deleted.
var _level_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.low_processor_usage_mode = true
	on_application_open()

func increment_node_id():
	_node_id += 1

func decrement_node_id():
	_node_id -= 1

func increment_level_id():
	_level_id += 1

func decrement_level_id():
	_level_id -= 1

"""
Handles the close request.
"""
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		on_application_close()

"""
Save the current state of the editor for next launch.
"""
func on_application_close():
	## Save the current project to an editor.json file?
	var editor_config_path = get_editor_conf_path() + "/config.json"
	var editor_config = FileAccess.open(editor_config_path, FileAccess.WRITE)
	## TODO: Check if the project is in a recents list in the config, add it, if it's not, should probably handle this when projects are created....
	if editor_config:
		var _state = {LAST_OPEN_PROJ_KEY : FileManager.get_current_project_dir()}
		var state_string = JSON.stringify(_state)
		editor_config.store_string(state_string)
		editor_config.close()
	else:
		return FileAccess.get_open_error()


"""
Opens the editor config file and sets the current project to the last open project, if no project was found, then it start's the application with a create project dialog. Will save the list of recent projects also at some point.
"""
func on_application_open():
	## If no previous project, start the application with the create project window.
	## TODO: Add a editor setting for this, either start with a list of projects, or open the last project.
	var editor_config_path = get_editor_conf_path() + "/config.json"
	var editor_config = FileAccess.open(editor_config_path, FileAccess.READ)
	if editor_config:
		## TODO: Save the currently open level's, and load them when the project opens.
		var _last_state = JSON.parse_string(editor_config.get_as_text())
		if _last_state[LAST_OPEN_PROJ_KEY].length() == 0:
			var create_proj = load("res://scenes/UI/Project_System/create_project_menu.tscn").instantiate()
			get_tree().current_scene.add_child(create_proj)
		FileManager.open_project(_last_state[LAST_OPEN_PROJ_KEY])
	else:
		return FileAccess.get_open_error()

"""
Helpful function that checks if the application is running in standalone, or in editor returns the path that we need to get the last state of the application.
"""
func get_editor_conf_path():
	if OS.has_feature("standalone"):
		var exec_path = OS.get_executable_path()
		var exec_dir = exec_path.get_base_dir()
		return exec_dir
	else:
		var running_in_editor_path = "C:/dev/projects/Godot/story-graph/build/debug"
		if DirAccess.dir_exists_absolute(running_in_editor_path):
			return running_in_editor_path
