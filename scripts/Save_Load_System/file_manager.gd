extends Node

"""
The file types of the application, this will be used to open the correct directory.
"""
enum FileType {
	LEVEL,
	TEMPLATE,
	PROJECT,
	CONFIG
}

##SIGNALS
signal level_create_requested()
signal save_focused_requested(_type : FileManager.FileType)
signal template_create_requested()

## const string literals for file saving and loading.
const LEVEL_FILE_TYPE = "level"
const TEMPLATE_FILE_TYPE = "json"
const PROJECT_FILE_TYPE = "project"
const CONFIG_FILE_TYPE = "config"

## The path to the currently open project
var _current_project_dir := ""

## Process new file requests and save requests of the active file.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_level"):
		level_create_requested.emit()
	elif event.is_action_pressed("save"):
		var focused = get_viewport().gui_get_focus_owner().is_in_group("Levels")
		if focused:
			save_focused_requested.emit(FileManager.FileType.LEVEL)
			return

"""
@return current project directory path
"""
func get_current_project_dir():
	return _current_project_dir

func is_in_active_proect():
	return FileAccess.file_exists(get_project_file())

"""
Opens a file, with only the name and type required, the method will append the correct file type.

@param _name: the name of the file to open.
@param _type: the type of file it is, IE. Level or template, see FileManager->LevelTypes
@param _access: The mode to open it in, IE, FileAccess.WRITE, see FilAccess for more modes
@param _status: An optional array that will contain any Errors from the operation.
@return opened file or null if the operation failed.
"""
func open_file(_name : String, _type : FileType, _access : FileAccess.ModeFlags, _status = []) -> FileAccess:
	var _file : FileAccess
	var _path : String
	match _type:
		FileType.LEVEL:
			_path = get_level_by_name(_name)
			_file = FileAccess.open(_path, _access)
		FileType.TEMPLATE:
			_path = get_template_by_name(_name)
			_file = FileAccess.open(_path, _access)

	if not _file:
		_status.append(FileAccess.get_open_error()) ## If opening failed, return the error
		return null

	return _file

"""
Saves the given data to a file of a relavant file type given the enum _type. Will create the file if it doesn't already exist.
@param _name: the name of the file to save.
@param _type: the type of the file to save.
@param _data: the contents to save to the file.
@return Error: OK, on success, or cant acquire resource if data was null, or the open_error that was experienced.
"""
func save_file(_name : String, _type : FileType, _data) -> Error:
	## If the data is null, return out.
	if not _data:
		return ERR_CANT_ACQUIRE_RESOURCE

	## Open it for writing
	var _status = []
	var _file = open_file(_name, _type, FileAccess.WRITE, _status)
	# If we have a file with no errors.
	if _file:
		_file.store_var(_data)
		_file.close()
		return OK
	else:
		print(error_string(_status[0]))
		return FileAccess.get_open_error()

"""
Loads a file with given name and type to disk if it exists and returns a dictionary of the contents of the file.
@param _file_name: the name of the file to load.
@param _type: the type of file to load.
@param _status: this array will contain any error's that might have taken place, will contain OK, if the operation was successful
@return contents: contents of the file if the operation was successful, otherwise empty dictionary
"""
func load_file(_file_name : String, _type : FileType, _status) -> Dictionary[StringName, Variant]:
	var contents : Dictionary[StringName, Variant] = {}
	if file_exists(_file_name, _type):
		var _file = open_file(_file_name, _type, FileAccess.READ)
		if _file:
			contents = _file.get_var()
		else:
			_status.append(FileAccess.get_open_error())
			return {}
	else:
		_status.append(ERR_DOES_NOT_EXIST)
		return {}
	_status.append(OK)
	return contents

"""
Checks if a file of a given type with given name already exists
"""
func file_exists(_name : String, _type : FileType) -> bool:
	var _path : String
	match _type:
		FileType.LEVEL:
			_path = get_level_by_name(_name)
		FileType.TEMPLATE:
			_path = get_template_by_name(_name)
	return FileAccess.file_exists(_path)

func open_project(project_path : String) -> Error:
	##Already open
	if project_path == _current_project_dir:
		return ERR_ALREADY_IN_USE
	#if the project file is present.
	if FileAccess.file_exists(project_path + "/story.project"):
		_current_project_dir = project_path
		## Set the window name to the project directory name
		set_application_title()
		return OK
	return ERR_DOES_NOT_EXIST

## Returns the root directory for the currently open project.
func get_open_project():
	return _current_project_dir

## Returns the path of the levels directory
func get_levels_directory():
	return "%s/levels" % _current_project_dir

## Returns the path of the level object
func get_level_by_name(level_name : String) -> String:
	return "%s/%s.%s" % [get_levels_directory(), level_name, LEVEL_FILE_TYPE]

## Returns the path of the templates directory
func get_templates_directory():
	return "%s/templates" % _current_project_dir

func get_template_by_name(_name : String) -> String:
	return "%s/%s.%s" % [get_templates_directory(), _name, TEMPLATE_FILE_TYPE]

## Returns the path of the story.project file
func get_project_file():
	return "%s/story.project" % _current_project_dir

func set_application_title():
	var tokens = _current_project_dir.split("/")
	get_tree().root.title += " - Project - " + tokens[tokens.size() - 1]
