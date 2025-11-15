extends Node

var unsaved_levels : Array[Level]

@export var PROJECT_HUB : PackedScene = preload("res://scenes/Project_System/project_hub.tscn")

#SIGNALS
signal project_changed()

## const string literals for storing project data
const TEMPLATE_KEY = "templates"
const LEVEL_KEY = "levels"
const ENUM_KEY = "enums"
const TEMPLATE_REFRENCES = "template_refrences" ## This keeps track of the node's that need to be updated when templates are edited.
const LEVEL_ID = "current_level_id"


## Const string literals for storing the state of the editor upon closing and opening.
const LAST_OPEN_PROJ_KEY = "last_open_project"
const LAST_OPEN_LEVELS = "open_levels"
const PROJECT_LIST = "project_list"


var current_level_id : int = -1

## The path to the currently open project
var _current_project_dir := ""

var _project_data : Dictionary

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_tree().auto_accept_quit = false
	OS.low_processor_usage_mode = true
	await on_application_open()

## Function to recover project if the .project file becomes corrupt.
func _recover(current_dir):
	var dirs := DirAccess.get_directories_at(current_dir)
	var files := DirAccess.get_files_at(current_dir)
	var items = dirs + files
	for item in items:
		var current_path = current_dir + "/" + item
		if DirAccess.dir_exists_absolute(current_path):
			_recover(current_path)
		match item.get_extension():
			"level":
				var level_id : int = JSON.parse_string(FileAccess.get_file_as_string(current_path))[Level.ID] as int
				if level_id > current_level_id:
					current_level_id = level_id
					_project_data[LEVEL_ID] = current_level_id
				if _project_data.has(LEVEL_KEY):
					_project_data[LEVEL_KEY].append(current_path)
				else:
					_project_data[LEVEL_KEY] = [current_path]
			"template":
				if _project_data.has(TEMPLATE_KEY):
					_project_data[TEMPLATE_KEY].append(current_path)
				else:
					_project_data[TEMPLATE_KEY] = [current_path]



## Increments the current level id and writes it the project file.
func increment_current_level_id() -> int:
	current_level_id = current_level_id + 1
	_project_data[LEVEL_ID] = current_level_id
	return current_level_id

func _read_project_data() -> Error:
	var project_file := FileAccess.open(get_project_file(), FileAccess.READ)
	if project_file:
		_project_data = JSON.parse_string(project_file.get_as_text())
		current_level_id = _project_data[LEVEL_ID]
	else:
		return FileAccess.get_open_error()
	project_file.close()
	return OK

##Handles the close request.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		on_application_close()


##@return current project directory path
func get_current_project_dir():
	return _current_project_dir

func get_project_data() -> Dictionary:
	return _project_data

## Appends the data on to an array within the project data dictionary. Will add the key to the dictionary if it doesn't already exist with an array value containing the data as an element.
func get_or_add_project_data(key : String, data = null) -> void:
	var items = _project_data.get(key)
	if items:
		items.append(data)
	else:
		_project_data[key] = [data]
	_write_project_data()

## Expects the item to be an array held in the project data dictionary with the given key
func remove_project_data(key : String, item):
	var items : Array = _project_data[key]
	items.erase(item)
	_write_project_data()

## Keeps the project data and the project file in sync. Call after a change to the file structure, and when the application is closed.
func _write_project_data() -> Error:
	var file = FileAccess.open(get_project_file(), FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_project_data, "\t", false))
	else:
		return FileAccess.get_open_error()
	file.close()
	return OK

func is_in_active_project():
	return FileAccess.file_exists(get_project_file())

## Returns the path to the project file, wrapper function so the save command will work for the project also.
func get_resource_path():
	return get_project_file()

func save():
	_write_project_data()

func open_project(project_path : String) -> Error:
	##Already open
	if project_path == _current_project_dir:
		return ERR_ALREADY_IN_USE
	#if the project file is present.
	if FileAccess.file_exists(project_path + "/" + "story.project"):
		_current_project_dir = project_path
		## Set the window name to the project directory name
		set_application_title()
		_read_project_data()
		project_changed.emit()
		return OK
	return ERR_DOES_NOT_EXIST

## Returns the path of the story.project file
func get_project_file():
	return "%s/story.project" % _current_project_dir

func set_application_title():
	var tokens = _current_project_dir.split("/")
	get_tree().root.title = "%s - Project - %s" % [ProjectSettings.get_setting("application/config/name"), tokens[tokens.size() - 1]]

##Save the current state of the editor for next launch.
func on_application_close():
	var selection = await unsaved_progress()
	match selection:
		PromptSelection.CANCEL:
			return
		PromptSelection.SAVE:
			for level in unsaved_levels:
				pass ## TODO: Implement this

	## Save the current project to open on the next launch...
	persistent_project()
	_write_project_data()
	get_tree().quit()


##Opens the editor config file and sets the current project to the last open project, if no project was found, then it start's the application with a create project dialog. Will save the list of recent projects also at some point.
func on_application_open():
	## Create the config file if it's missing.
	if not FileAccess.file_exists(get_editor_conf_path()):
		var config = FileAccess.open(get_editor_conf_path(), FileAccess.WRITE)
		config.close()

	var hub : ProjectHub = PROJECT_HUB.instantiate()
	get_tree().current_scene.add_child(hub)
	var _path = await hub.on_selection

	## TODO: Enable this when editor settings are complete.
	##load_persistent_project()


##Helpful function that checks if the application is running in standalone, or in editor returns the path that we need to get the last state of the application. Defaults to build/debug while running in editor.
func get_editor_conf_path():
	if OS.has_feature("standalone"):
		var exec_path = OS.get_executable_path()
		var exec_dir = exec_path.get_base_dir()
		return exec_dir + "/config.json"
	else:
		var running_in_editor_path = "C:/dev/projects/Godot/story-graph/build/Windows/Debug"
		if DirAccess.dir_exists_absolute(running_in_editor_path):
			return running_in_editor_path + "/config.json"

## Appends a project to the end of the project list in the editor config.
func add_project_to_list(_value : Dictionary[String, String]) -> Error:
	var config = get_editor_conf_path()
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
	if config and config.get_length() > 0:
		var content = JSON.parse_string(config.get_as_text())
		config.close()
		if content:
			return content[PROJECT_LIST]
	else:
		return null

func unsaved_progress():
	if unsaved_levels.size() > 0:
		##TODO: Fix this!!!
		var save_win = load("res://scenes/Popups/unsaved_close_prompt.tscn").instantiate()
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
		_state = {LAST_OPEN_PROJ_KEY : GraphEditor.get_current_project_dir()}
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
		open_project(_last_state[LAST_OPEN_PROJ_KEY])
		await get_tree().create_timer(1.0).timeout ## Give the scene tree time to load.
		if _last_state.get(LAST_OPEN_LEVELS):
			for level in _last_state[LAST_OPEN_LEVELS]:
				pass
				## TODO: Implement this
	else:
		return FileAccess.get_open_error()
