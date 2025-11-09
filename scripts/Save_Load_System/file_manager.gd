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

##@return current project directory path
func get_current_project_dir():
	return _current_project_dir

func is_in_active_project():
	return FileAccess.file_exists(get_project_file())

func get_type_by_path(_path : String):
	var extension = _path.get_extension()
	if extension == LEVEL_FILE_TYPE:
		return FileType.LEVEL
	elif extension == TEMPLATE_FILE_TYPE:
		return FileType.TEMPLATE

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

## Returns the path of the story.project file
func get_project_file():
	return "%s/story.project" % _current_project_dir

func set_application_title():
	var tokens = _current_project_dir.split("/")
	get_tree().root.title = "%s - Project - %s" % [ProjectSettings.get_setting("application/config/name"), tokens[tokens.size() - 1]]

func create_directory(_path : String, _name : StringName = "New Folder"):
	_path = _path + "/%s" % _name
	DirAccess.make_dir_recursive_absolute(_path)

func rename_directory(_from : String, _to : String) -> int:
	return DirAccess.rename_absolute(_from, _to)
