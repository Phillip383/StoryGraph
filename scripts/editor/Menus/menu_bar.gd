extends PanelContainer

const NEW_LEVEL_ID = 0
const CREATE_PROJECT_ID = 1
const OPEN_PROJECT_ID = 2
const OPEN_LEVEL_ID = 3
@export var PROJECT_CREATION_WINDOW : PackedScene
@export var OPEN_PROJECT_WINDOW : PackedScene
@export var OPEN_LEVEL_DIALOG : PackedScene

@onready var command_invoker : CommandInvoker = CommandInvoker.new()

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
	elif id == OPEN_LEVEL_ID:
		open_level()

func open_level():
	var open_proj_window : FileDialog = OPEN_LEVEL_DIALOG.instantiate()
	open_proj_window.title = "Open Level"
	open_proj_window.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	open_proj_window.root_subfolder = GraphEditor.get_current_project_dir()
	open_proj_window.add_filter("*%s" % FileIO.LEVEL_EXT)
	open_proj_window.file_selected.connect(on_level_opened)
	get_tree().current_scene.add_child(open_proj_window)

func on_level_opened(path : String):
	command_invoker.set_command(OpenFileCommand.new(path)).execute_command()

## Connection from the new level window in the level's container.
func _on_open_existing_level_pressed() -> void:
	open_level()

## Sends the signal to the level container to create a new level.
func _on_create_new_pressed() -> void:
	var new_file_command = NewFileCommand.new(FileTypes.Types.LEVEL)
	command_invoker.set_command(new_file_command).execute_command()
	await new_file_command.file_created
