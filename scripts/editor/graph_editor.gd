extends CanvasLayer

var unsaved_levels : Array[Level]

## Const string literals for storing the state of the editor upon closing and opening.
const LAST_OPEN_PROJ_KEY = "last_open_project"
const LAST_OPEN_LEVELS = "open_levels"

## TODO: Move this to the level class, as a level will be responsible for id'ing it's nodes. need to link to the signal for add_node or delete node and set the ID on the node, or decrement it here upon deletion.
var _node_id : int ## This will increment whenever a node is added or decrement on delete

## TODO: use this level id for levels, make it unique! A level can be a table, and the composite key between a unique level id and a unique node id will ensure the correct linking of nodes between levels. Increment this when a level is created, decrement when a level is deleted.
var _level_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().auto_accept_quit = false
	OS.low_processor_usage_mode = true
	await on_application_open()

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
	var selection = await unsaved_progress()
	match selection:
		PromptSelection.CANCEL:
			return
		PromptSelection.SAVE:
			for level in unsaved_levels:
				FileManager.save_file(level.name, FileManager.FileType.LEVEL, level.save_level())
	
	## Save the current project to open on the next launch...
	persistent_project()
	get_tree().quit()


"""
Opens the editor config file and sets the current project to the last open project, if no project was found, then it start's the application with a create project dialog. Will save the list of recent projects also at some point.
"""
func on_application_open():
	var editor_config_path = get_editor_conf_path() + "/config.json"
	var editor_config = FileAccess.open(editor_config_path, FileAccess.READ)
	if editor_config:
		var _last_state = JSON.parse_string(editor_config.get_as_text())
		if _last_state[LAST_OPEN_PROJ_KEY].length() == 0:
			var create_proj = load("res://scenes/UI/Project_System/create_project_menu.tscn").instantiate()
			get_tree().current_scene.add_child(create_proj)

		FileManager.open_project(_last_state[LAST_OPEN_PROJ_KEY])
		await get_tree().create_timer(1.0).timeout
		if _last_state.get(LAST_OPEN_LEVELS):
			for level in _last_state[LAST_OPEN_LEVELS]:
				var _status = []
				FileManager.load_file_by_name(level, FileManager.FileType.LEVEL, _status)
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

## TODO: Flesh this out tomorrow add a widget that list's the unsaved level's and save them upon approval, or discard them, or cancel the quit.
func unsaved_progress():
	if unsaved_levels.size() > 0:
		var save_win = load("res://scenes/UI/Popups/unsaved_close_prompt.tscn").instantiate()
		get_tree().current_scene.add_child(save_win)
		var unsaved_level_names = ""
		for level in unsaved_levels:
			unsaved_level_names += "%s%s" % [level.name, "\n"]
			
		save_win.set_unsaved_progress_text(unsaved_level_names)
		return await save_win.on_selection

func persistent_project():
	var editor_config_path = get_editor_conf_path() + "/config.json"
	var editor_config = FileAccess.open(editor_config_path, FileAccess.WRITE)
	if editor_config:
		var _state = {LAST_OPEN_PROJ_KEY : FileManager.get_current_project_dir()}
		_state[LAST_OPEN_LEVELS] = persistent_levels()
		var state_string = JSON.stringify(_state)
		editor_config.store_string(state_string)
		editor_config.close()
	else:
		return FileAccess.get_open_error()

func persistent_levels():
	## Get currently open levels.
	var open_levels = get_tree().get_nodes_in_group("Levels")
	var levels = []
	for level in open_levels:
		levels.append(level.name)
	return levels
