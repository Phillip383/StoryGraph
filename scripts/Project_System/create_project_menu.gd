extends Window

const OPEN_PROJECT_DIALOG = preload("res://scenes/UI/Project_System/open_project_dialog.tscn")
const DIRECTORY_NOT_FOUND_MSG = "Directory Not Found!"
const DIRECTORY_FAILURE = "Failed To Create Directory! Check Path"
const FILE_FAILURE = "Failed To Create File!"
const PROJECT_NAME_FAILURE = "Invalid Project Name!"

@onready var description_box : TextEdit = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Description
@onready var message_box : Label = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Label
@onready var project_path_edit : LineEdit = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Location/ProjectPath
@onready var file_dialog : FileDialog = $FileDialog

var project_path := ""
var project_name := ""
var description := ""

## This is the actual path we will use, we need to retain the original path to go back to a better state after a failure.
var intermediate_project_path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(_on_cancel_pressed)
	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)

## Returns OK if creation was successful, and any file or directory related error's upon failure.
func create_project() -> Error:
	message_box.visible = false ## Reset the message_box.
	## Check if path is valid, if not throw error.
	var _error = DirAccess.dir_exists_absolute(project_path)
	if not _error:
		handle_error(DIRECTORY_NOT_FOUND_MSG)
		return ERR_DOES_NOT_EXIST

	## Setup the necessary components for project creation.
	var PROJECT_STRUCTURE = declare_project_structure()
	_error = sanitize_data_for_creation()
	if _error != OK:
		return _error

	_error = create_project_dir()
	if _error != OK:
		handle_error(DIRECTORY_FAILURE)
		return _error

	## Create the intermediate project files.
	return create_project_structure(PROJECT_STRUCTURE)

## The structure of the project directory in dictionary format, this is useful if I ever make changes to how I want a project to be created.
## Directories are suffixed with _dir and files with _f, these suffixes are removed upon creation.
func declare_project_structure():
	var project_structure = {
		project_name : {
			"levels_dir" : null, # The directory where graphs will be saved.
			"templates_dir" : null, # A directory where data templates will be stored for faster iteration of similar data models. 
			"story.project_f" : null # A file where project information will be stored.
		}
	}
	return project_structure

"""
Transmutes the data into an acceptable format, and resets the state of the path variable.
Replaces the windows \\ with unix / in the path; appends the project name to the project path...
Ensure this is called after checking for a valid top level path...
Throws an error if the project name is empty..
"""
func sanitize_data_for_creation() -> Error:
	## Reset the project_path
	intermediate_project_path = project_path
	if project_name.length() == 0:
		handle_error(PROJECT_NAME_FAILURE)
		return ERR_INVALID_DATA
	description = description_box.text
	intermediate_project_path = project_path.replace("\\", "/") + "/" + project_name # Replace windows \ with unix style /
	return OK

## Helper function that prints a error message to the user on the project creation screen.
func handle_error(error_message : String):
	message_box.visible = true
	message_box.text = error_message

func create_dir(path : String) -> Error:
	var _error = DirAccess.make_dir_absolute(path)
	return _error

func create_file(path : String) -> Error:
	var _file = FileAccess.open(path, FileAccess.WRITE)
	if _file == null:
		return FileAccess.get_open_error()
	
	if path.contains(".project"):
		if not create_project_file(_file):
			handle_error(FILE_FAILURE)
			return ERR_FILE_CANT_WRITE

	return OK

## Creates the project file with relative information for the project, IE. name, an optional description.
## Will store project setting's as well.
## Returns true if the operation was successful
func create_project_file(_file : FileAccess) -> bool:
	var successful
	successful = _file.store_string("Project Name: " + project_name + "\n")
	if description.length() > 0:
		successful = _file.store_string("description: " + description + "\n")
	_file.close()
	return successful

## Recursively creates the top level project directory returns the error code from the operation.
func create_project_dir() -> Error:
	return DirAccess.make_dir_recursive_absolute(intermediate_project_path)

## Creates the intermediate files and directories for the project throws an error for any operation that fails.
func create_project_structure(structure) -> Error:
	var _error : Error
	for object in structure[project_name]:
		var dir_str = object as String
		if dir_str.contains("_dir"):
			dir_str = dir_str.get_slice("_", 0)
			_error = create_dir(intermediate_project_path + "/" + dir_str)
			if _error != OK:
				handle_error(DIRECTORY_FAILURE + " :: " + error_string(_error))
				return _error
		elif dir_str.contains("_f"):
			dir_str = dir_str.get_slice("_", 0)
			_error = create_file(intermediate_project_path + "/" + dir_str)
			if _error != OK:
				handle_error(FILE_FAILURE + " :: " + error_string(_error))
				return _error
	return OK

func _on_project_name_text_changed(new_text: String) -> void:
	project_name = new_text

func _on_file_explorer_pressed() -> void:
	file_dialog.show()

func _on_file_dialog_dir_selected(dir : String):
	project_path = dir
	project_path_edit.text = dir

func _on_project_path_text_changed(new_text: String) -> void:
	project_path = new_text

func _on_cancel_pressed() -> void:
	queue_free()

## Only destroys the create project window if it was successful
func _on_create_pressed() -> void:
	if create_project() == OK:
		queue_free()

## creates the open project dialog and adds it the scene tree.
func _on_open_existing_pressed() -> void:
	var open_dialog : OpenProjectDialog = OPEN_PROJECT_DIALOG.instantiate()
	get_tree().current_scene.add_child(open_dialog)
	await open_dialog.on_successful_selection
	queue_free()