extends Node


##The file types of the application, this will be used to open the correct directory.
enum FileType {
	LEVEL,
	TEMPLATE,
	PROJECT,
	CONFIG
}

##SIGNALS
signal level_create_requested()
signal on_level_load_request(_level_data)
signal post_level_load(_level : Level)

signal save_focused_requested(_type : FileManager.FileType)

signal project_changed()

signal level_deleted(_name : StringName)
signal level_renamed(_old_name : StringName, _new_name : StringName)

# signal template_create_requested()
# signal on_template_load_request(_template)

## const string literals for file saving and loading.
const LEVEL_FILE_TYPE = "level"
const TEMPLATE_FILE_TYPE = "json"
const PROJECT_FILE_TYPE = "project"
const CONFIG_FILE_TYPE = "json"

## The path to the currently open project
var _current_project_dir := ""

## Process new file requests and save requests of the active file.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_level"):
		level_create_requested.emit()
	elif event.is_action_pressed("save"):
		var focused = get_viewport().gui_get_focus_owner()
		if focused and focused.is_in_group("Levels"):
			save_focused_requested.emit(FileManager.FileType.LEVEL)
			return
	elif event.is_action_pressed("save_all"):
		##TODO: Add everything I want to save to a group, gather it, loop over them calling their save function. This will require a refactor.
		pass

##@return current project directory path
func get_current_project_dir():
	return _current_project_dir

func is_in_active_project():
	return FileAccess.file_exists(get_project_file())

## Returns a path to the renamed file...
func rename_file(_path : String, _name : StringName) -> String:
	match get_type_by_path(_path):
		FileType.LEVEL:
			return _rename_level(_path, _name)
	return ""

func _rename_level(_path : String, _name : StringName) -> String:
	var _new_path = _path.substr(0, _path.rfind("/") + 1) + _name + ".%s" % LEVEL_FILE_TYPE
	DirAccess.rename_absolute(_path, _new_path)
	## Get the file name without the extension for the old and new.
	var _old_name = _path.substr(_path.rfind("/") + 1).get_slice(".", 0)
	var _new_name = _new_path.substr(_path.rfind("/") + 1).get_slice(".", 0)
	level_renamed.emit(_old_name, _new_name)
	return _new_name

func get_type_by_path(_path : String):
	var extension = _path.get_extension()
	if extension == LEVEL_FILE_TYPE:
		return FileType.LEVEL
	elif extension == TEMPLATE_FILE_TYPE:
		return FileType.TEMPLATE

func delete_file(_path : String):
	DirAccess.remove_absolute(_path)
	match get_type_by_path(_path):
		FileType.LEVEL:
			var _name = _path.substr(_path.rfind("/") + 1)
			level_deleted.emit(_name)

## Opens a file, with only the name and type required, the method will append the correct file type.
## @param _name: the name of the file to open.
## @param _type: the type of file it is, IE. Level or template, see FileManager->LevelTypes
## @param _access: The mode to open it in, IE, FileAccess.WRITE, see FilAccess for more modes
## @param _status: An optional array that will contain any Errors from the operation.
## @return opened file or null if the operation failed.
func open_file(_name : String, _type : FileType, _access : FileAccess.ModeFlags, _status = []) -> FileAccess:
	var _file : FileAccess
	var _path : String
	match _type:
		FileType.LEVEL:
			_file = _open_level_by_name(_name, _access)
		FileType.TEMPLATE:
			_file = _open_template_by_name(_name, _access)

	if not _file:
		_status.append(FileAccess.get_open_error()) ## If opening failed, return the error
		return null

	return _file

func _open_level_by_name(_name, access) -> FileAccess:
	var path = get_level_by_name(_name)
	return FileAccess.open(path, access)

func _open_template_by_name(_name, access) -> FileAccess:
	var path = get_template_by_name(_name)
	return FileAccess.open(path, access)

## Saves the given data to a file of a relevant file type given the enum _type. Will create the file if it doesn't already exist.
## @param _name: the name of the file to save.
## @param _type: the type of the file to save.
## @param _data: the contents to save to the file.
## @return Error: OK, on success, or cant acquire resource if data was null, or the open_error that was experienced.
func save_file(_name : String, _type : FileType, _data) -> Error:
	## If the data is null, return out.
	if not _data:
		return ERR_CANT_ACQUIRE_RESOURCE

	## Open it for writing
	var _status = []
	var _file = open_file(_name, _type, FileAccess.WRITE, _status)
	# If we have a file with no errors.
	if _file:
		## TODO: Change this to json and encrypt it, this isn't safe.
		_file.store_var(_data)
		_file.close()
		return OK
	else:
		print(error_string(_status[0]))
		return FileAccess.get_open_error()


## Loads a file with given name and type to disk if it exists and returns a dictionary of the contents of the file.
## @param _file_name: the name of the file to load.
## @param _type: the type of file to load.
## @param _status: this array will contain any error's that might have taken place, will contain OK, if the operation was successful
## @return contents: contents of the file if the operation was successful, otherwise empty dictionary
func load_file_by_name(_file_name : String, _type : FileType, _status) -> Dictionary[StringName, Variant]:
	var contents : Dictionary[StringName, Variant] = {}
	if file_exists(_file_name, _type):
		var _file = open_file(_file_name, _type, FileAccess.READ)
		if _file:
			contents = _file.get_var()
			contents["name"] = _file_name ## If the file has been renamed since it's last open.
			on_level_load_request.emit(contents)
		else:
			_status.append(FileAccess.get_open_error())
			return {}
	else:
		_status.append(ERR_DOES_NOT_EXIST)
		return {}
	_status.append(OK)
	return contents


## Loads a file by it's path, internally checks it's type by the file's suffix.
func load_file_by_path(_path : String):
	##TODO: Add type checking from paths, a contains reverse search would be best.
	var _file = FileAccess.open(_path, FileAccess.READ)
	if _file:
		## TODO: Change this to json and encrypt it, this isn't safe.
		var _data = _file.get_var()
		## Get the name of the file and store it, if the file has been renamed since it's last open and save.
		_data["name"] = _path.substr(_path.rfind("/") + 1, _path.rfind("."))
		on_level_load_request.emit(_data)
		_file.close()
	else:
		return FileAccess.get_open_error()


## Checks if a file of a given type with given name already exists
func file_exists(_name : String, _type : FileType) -> bool:
	var _path : String
	## If the name doesn't have the type appended already, append it.
	match _type:
		FileType.LEVEL:
			_path = get_level_by_name(_name)
		FileType.TEMPLATE:
			_path = get_template_by_name(_name)
	return FileAccess.file_exists(_path)

func file_exists_by_path(_path : String, _name) -> bool:
	var path : String = _path.substr(0, _path.rfind("/") + 1) + _name
	match get_type_by_path(_path):
		FileType.LEVEL:
			path = path + ".%s" % LEVEL_FILE_TYPE
		FileType.TEMPLATE:
			pass ## TODO: add template check...
	return FileAccess.file_exists(path)

func open_project(project_path : String) -> Error:
	##Already open
	if project_path == _current_project_dir:
		return ERR_ALREADY_IN_USE
	#if the project file is present.
	if FileAccess.file_exists(project_path + "/story.project"):
		_current_project_dir = project_path
		## Set the window name to the project directory name
		set_application_title()
		project_changed.emit()
		return OK
	return ERR_DOES_NOT_EXIST

func add_project_to_list(_proj : Dictionary[String, String]) -> void:
	GraphEditor.add_project_to_list(_proj)

## Returns the path of the levels directory
func get_levels_directory():
	return "%s/levels" % _current_project_dir

## Returns the path of the level object
func get_level_by_name(level_name : String) -> String:
	var _path : String = ""
	if level_name.contains(LEVEL_FILE_TYPE):
		return "%s/%s" % [get_levels_directory(), level_name]
	return "%s/%s.%s" % [get_levels_directory(), level_name, LEVEL_FILE_TYPE]

## Returns the path of the templates directory
func get_templates_directory():
	return "%s/templates" % _current_project_dir

func get_template_by_name(_name : String) -> String:
	if _name.contains(TEMPLATE_FILE_TYPE):
		return "%s/%s" % [get_templates_directory(), _name]
	return "%s/%s.%s" % [get_templates_directory(), _name, TEMPLATE_FILE_TYPE]

## Returns the path of the story.project file
func get_project_file():
	return "%s/story.project" % _current_project_dir

func set_application_title():
	var tokens = _current_project_dir.split("/")
	get_tree().root.title = "%s - Project - %s" % [ProjectSettings.get_setting("application/config/name"), tokens[tokens.size() - 1]]

func create_directory(_path : String, _name : StringName = "New Folder"):
	_path = _path + "/%s" % _name
	DirAccess.make_dir_recursive_absolute(_path)

func move_file(_from_path : String, _to_path : String):
	var err = DirAccess.copy_absolute(_from_path, _to_path)
	assert(err == OK, "move file failed: " + error_string(err))
	if err == OK:
		if DirAccess.dir_exists_absolute(_from_path):
			DirAccess.remove_absolute(_from_path)
