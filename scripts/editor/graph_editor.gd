extends Node

var unsaved_levels : Array[Level]

@export var PROJECT_HUB : PackedScene = preload("res://scenes/UI/Project_System/project_hub.tscn")


## Const string literals for storing the state of the editor upon closing and opening.
const LAST_OPEN_PROJ_KEY = "last_open_project"
const LAST_OPEN_LEVELS = "open_levels"
const PROJECT_LIST = "project_list"

## TODO: use this level id for levels, make it unique! A level can be a table, and the composite key between a unique level id and a unique node id will ensure the correct linking of nodes between levels. Increment this when a level is created, decrement when a level is deleted.
var _level_id : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().auto_accept_quit = false
	OS.low_processor_usage_mode = true
	await on_application_open()

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
	var hub= PROJECT_HUB.instantiate()
	get_tree().current_scene.add_child(hub)
	## TODO: Enable this when editor settings are complete.
	##load_persistent_project()


##Helpful function that checks if the application is running in standalone, or in editor returns the path that we need to get the last state of the application. Defaults to build/debug while running in editor.
func get_editor_conf_path():
	if OS.has_feature("standalone"):
		var exec_path = OS.get_executable_path()
		var exec_dir = exec_path.get_base_dir()
		return exec_dir + "/config.json"
	else:
		var running_in_editor_path = "C:/dev/projects/Godot/story-graph/build/debug"
		if DirAccess.dir_exists_absolute(running_in_editor_path):
			return running_in_editor_path + "/config.json"

## Appends a project to the end of the project list in the editor config.
func add_project_to_list(_value : Dictionary[String, String]) -> Error:
	var config = get_or_add_editor_config()
	var _file : FileAccess = FileAccess.open(config, FileAccess.READ_WRITE)
	var content = {}
	if _file:
		if _file.get_length() > 0:
			content = JSON.parse_string(_file.get_as_text())
			if content and content.get(PROJECT_LIST):
				content[PROJECT_LIST].append(_value)
			else:
				content[PROJECT_LIST] = [_value]
			_file.store_string(JSON.stringify(content))
			_file.close()
			return OK
		else:
			content[PROJECT_LIST] = [_value]
			_file.store_string(JSON.stringify(content))
			_file.close()
			return OK
	else:
		return FileAccess.get_open_error()

## Gets the editor config path, or create's it, if it doesn't exist.
func get_or_add_editor_config():
	var con_path = get_editor_conf_path()
	if FileAccess.file_exists(con_path):
		return con_path
	var _file = FileAccess.open(con_path, FileAccess.WRITE)
	_file.close()
	return get_editor_conf_path()

func remove_project_from_list(_project_name : String):
	var proj_list = get_project_list()
	var content
	if proj_list:
		## Filters the array of dictionaries, not including the project with the given name.
		var filtered_projects = proj_list.filter( func(p: Dictionary): return p.keys().size() > 0 and p.keys()[0] != _project_name)
		var config = get_editor_conf_path()
		var _file : FileAccess = FileAccess.open(config, FileAccess.READ)
		if _file:
			content = JSON.parse_string(_file.get_as_text())
			content[PROJECT_LIST] = filtered_projects
			_file.close()
		_file = FileAccess.open(config, FileAccess.WRITE)
		if _file:
			_file.store_string(JSON.stringify(content))

## Get's the project list from the editor config.
func get_project_list():
	var config : FileAccess = FileAccess.open(get_editor_conf_path(), FileAccess.READ)
	if config:
		var content = JSON.parse_string(config.get_as_text())
		config.close()
		if content:
			return content[PROJECT_LIST]
	else:
		return null

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
	var editor_config_path = get_editor_conf_path()
	var _proj_list = get_project_list()
	var _state = JSON.parse_string(FileAccess.get_file_as_string(editor_config_path))
	var editor_config = FileAccess.open(editor_config_path, FileAccess.WRITE)
	if editor_config:
		_state = {LAST_OPEN_PROJ_KEY : FileManager.get_current_project_dir()}
		_state.get_or_add(LAST_OPEN_LEVELS, persistent_levels())
		_state.get_or_add(PROJECT_LIST, _proj_list)
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

func load_persistent_project():
	var editor_config_path = get_editor_conf_path()
	var editor_config = FileAccess.open(editor_config_path, FileAccess.READ)
	if editor_config:
		var _last_state = JSON.parse_string(editor_config.get_as_text())
		FileManager.open_project(_last_state[LAST_OPEN_PROJ_KEY])
		await get_tree().create_timer(1.0).timeout ## Give the scene tree time to load.
		if _last_state.get(LAST_OPEN_LEVELS):
			for level in _last_state[LAST_OPEN_LEVELS]:
				var _status = []
				FileManager.load_file_by_name(level, FileManager.FileType.LEVEL, _status)
	else:
		return FileAccess.get_open_error()
