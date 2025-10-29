extends PanelContainer

const NEW_LEVEL_ID = 0
const CREATE_PROJECT_ID = 1
const OPEN_PROJECT_ID = 2
const OPEN_LEVEL_ID = 3
const PROJECT_CREATION_WINDOW = preload("res://scenes/UI/Project_System/create_project_menu.tscn")
const OPEN_PROJECT_WINDOW = preload("res://scenes/UI/Project_System/open_project_dialog.tscn")
const NEW_LEVEL_WINDOW = ""

## Emitted when a new level is requested to be created from the menu bar.
signal new_level_request()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _on_file_id_pressed(id: int) -> void:
	if id == CREATE_PROJECT_ID:
		var proj_screen = PROJECT_CREATION_WINDOW.instantiate()
		get_tree().current_scene.add_child(proj_screen)
	elif id == OPEN_PROJECT_ID:
		var open_project_dialog = OPEN_PROJECT_WINDOW.instantiate()
		get_tree().current_scene.add_child(open_project_dialog)
	elif id == NEW_LEVEL_ID:
		new_level_request.emit()
	elif id == OPEN_LEVEL_ID:
		open_level()

func open_level():
	## TODO: Open file dialog and load the selected file
	var file_dialog : FileDialog = OPEN_PROJECT_WINDOW.instantiate()
	file_dialog.title = "Open Level"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.root_subfolder = FileManager.get_levels_directory()
	file_dialog.add_filter("*.%s" % FileManager.LEVEL_FILE_TYPE)
	file_dialog.file_selected.connect(on_level_opened)
	get_tree().current_scene.add_child(file_dialog)

func on_level_opened(path : String):
	FileManager.load_file_by_path(path)
