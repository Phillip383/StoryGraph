extends PanelContainer

const NEW_LEVEL_ID = 0
const CREATE_PROJECT_ID = 1
const OPEN_PROJECT_ID = 2
const OPEN_LEVEL_ID = 3
@export var PROJECT_CREATION_WINDOW : PackedScene
@export var OPEN_PROJECT_WINDOW : PackedScene
@export var OPEN_LEVEL_DIALOG : PackedScene

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
	var open_proj_window : FileDialog = OPEN_LEVEL_DIALOG.instantiate()
	open_proj_window.title = "Open Level"
	open_proj_window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_proj_window.root_subfolder = FileManager.get_levels_directory()
	open_proj_window.add_filter("*.%s" % FileManager.LEVEL_FILE_TYPE)
	open_proj_window.file_selected.connect(on_level_opened)
	get_tree().current_scene.add_child(open_proj_window)

func on_level_opened(path : String):
	FileManager.load_file_by_path(path)
