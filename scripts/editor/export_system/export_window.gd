extends Window

@export_file var OPEN_DIR_WINDOW = "res://scenes/Project_System/open_project_dialog.tscn"
@export_file var WARNING_POPUP_WINDOW = "res://scenes/Popups/warning_popup.tscn"

const INVALID_FORMAT_MESSAGE = "Invalid Export Format Provided."
const INVALID_PATH_MESSAGE = "Invalid Path, Directory doesn't exist."

@onready var _export_type_button = $PanelContainer/CenterContainer/VBoxContainer/HBoxContainer/ExportFormat
@onready var _export_button = $PanelContainer/CenterContainer/VBoxContainer/Buttons/Export
@onready var _path_edit = $PanelContainer/CenterContainer/VBoxContainer/ExportPath/PathEdit

@onready var _command_invoker = CommandInvoker.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(queue_free)
	_add_export_types()


func _on_export_pressed() -> void:
	if _export_type_button.selected == -1:
		_show_warning(INVALID_FORMAT_MESSAGE)
		return

	var export_type = _export_type_button.get_selected_id()
	var export_path = _path_edit.text
	if not DirAccess.dir_exists_absolute(export_path):
		_show_warning(INVALID_PATH_MESSAGE)
		return
	var export_command = ExportCommand.new(export_type, export_path)
	_command_invoker.set_command(export_command).execute_command()
	## TODO: Show progress
	queue_free()


func _on_cancel_pressed() -> void:
	queue_free()


func _on_path_selector_pressed() -> void:
	var file_dialog : OpenProjectDialog = load(OPEN_DIR_WINDOW).instantiate()
	add_child(file_dialog)
	file_dialog.size = Vector2i(1200, 600)
	file_dialog.initial_position = Window.WINDOW_INITIAL_POSITION_CENTER_PRIMARY_SCREEN
	file_dialog.title = "Export Path"
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM

	_path_edit.text = await file_dialog.dir_selected


func _on_path_edit_text_submitted(new_text: String) -> void:
	_on_export_pressed()

func _set_export_button_state(state : bool):
	_export_button.disabled = state

func _add_export_types():
	_export_type_button.add_item("JSON", ExportTypes.Types.JSON_EXPORT)
	_export_type_button.add_item("CSV", ExportTypes.Types.CSV_EXPORT)

func _show_warning(message : String):
	var warn_window : WarningPopup = load(WARNING_POPUP_WINDOW).instantiate()
	warn_window.set_message(message)
