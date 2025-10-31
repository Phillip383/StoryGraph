extends CanvasLayer

var unsaved_levels : Array[Level]

const PROJECT_HUB = preload("res://scenes/UI/project_System/project_hub.tscn")


## Const string literals for storing the state of the editor upon closing and opening.
const LAST_OPEN_PROJ_KEY = "last_open_project"
const LAST_OPEN_LEVELS = "open_levels"
const PROJECT_LIST = "project_list"

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
	var hub= PROJECT_HUB.instantiate()
	get_tree().current_scene.add_child(hub)
	## TODO: Enable this when editor settings are complete.
	# var editor_config_path = get_editor_conf_path()
	# var editor_config = FileAccess.open(editor_config_path, FileAccess.READ)
	# if editor_config:
	# 	var _last_state = JSON.parse_string(editor_config.get_as_text())
	# 	if _last_state[LAST_OPEN_PROJ_KEY].length() == 0:
	# 		var create_proj = load("res://scenes/UI/Project_System/create_project_menu.tscn").instantiate()
	# 		get_tree().current_scene.add_child(create_proj)

	# 	FileManager.open_project(_last_state[LAST_OPEN_PROJ_KEY])
	# 	await get_tree().create_timer(1.0).timeout ## Give the scene tree time to load.
	# 	if _last_state.get(LAST_OPEN_LEVELS):
	# 		for level in _last_state[LAST_OPEN_LEVELS]:
	# 			var _status = []
	# 			FileManager.load_file_by_name(level, FileManager.FileType.LEVEL, _status)
	# else:
	# 	return FileAccess.get_open_error()


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
	var config = get_editor_conf_path()
	var _file : FileAccess = FileAccess.open(config, FileAccess.READ_WRITE)
	if _file:
		var content = JSON.parse_string(_file.get_as_text())
		#assert(content == null, "Editor content could not be read")
		if content.get(PROJECT_LIST):
			content[PROJECT_LIST].append(_value)
		else:
			content[PROJECT_LIST] = [_value]
		_file.store_string(JSON.stringify(content))
		_file.close()
		return OK
	else:
		return FileAccess.get_open_error()

## Get's the project list from the editor config.
func get_project_list():
	var config : FileAccess = FileAccess.open(get_editor_conf_path(), FileAccess.READ)
	if config:
		var content = JSON.parse_string(config.get_as_text())
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
