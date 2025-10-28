extends Window

const DIRECTORY_NOT_FOUND_MSG = "Directory Not Found!"
const DIRECTORY_FAILURE = "Failed To Create Directory!"
const FILE_FAILURE = "Failed To Create File!"


@onready var description_box : TextEdit = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Description
@onready var message_box : Label = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Label
@onready var project_path_edit : LineEdit = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/Location/ProjectPath
@onready var file_dialog : FileDialog = $FileDialog

var project_path
var project_name
var description := ""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(_on_cancel_pressed)
	file_dialog.dir_selected.connect(_on_file_dialog_dir_selected)

## Return true if project was create, false otherwise.
func create_project() -> bool:

	## Project structure can easily be changed here as the algorithm below will create what is here. However, it will not create nested files and directories, if i add that, then I'll change the algorithm to support it.
	var PROJECT_STRUCTURE = {
		project_name : {
			"levels_dir" : null, # The directory where graphs will be saved.
			"templates_dir" : null, # A directory where data templates will be stored for faster iteration of similar data models. 
			"config_f" : null # A text file where project information will be stored.
		}
	}
	
	description = description_box.text

	project_path = project_path.replace("\\", "/") # Replace windows \ with unix style /
	## Check if path is valid, if not throw error.
	if DirAccess.dir_exists_absolute(project_path):
		## Make the top level project directory...
		var proj_path = project_path + "/" + project_name
		var _error_code = DirAccess.make_dir_recursive_absolute(proj_path)
		## Create the intermediate project files.
		for object in PROJECT_STRUCTURE[project_name]:
			var dir_str = object as String
			if dir_str.contains("_dir"):
				dir_str = dir_str.get_slice("_", 0)
				_error_code = DirAccess.make_dir_absolute(proj_path + "/" + dir_str)
				if _error_code != OK:
					message_box.visible = true
					message_box.text = DIRECTORY_FAILURE

			elif dir_str.contains("_f"):
				dir_str = dir_str.get_slice("_", 0)
				var file = FileAccess.open(proj_path + "/" + dir_str, FileAccess.WRITE)
				if not file:
					message_box.visible = true
					message_box.text = FILE_FAILURE

				if description.length() > 0:
					file.store_string("description: " + description)
				file.close()
		
		return true ## If we made it here everything is good...
	else:
		message_box.visible = true
		message_box.text = DIRECTORY_NOT_FOUND_MSG
		return false

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
	if create_project():
		queue_free()

## Queries the information every time it's changed to ensure it's in a good state to create a project.
func confirm_button_state() -> void:
	pass