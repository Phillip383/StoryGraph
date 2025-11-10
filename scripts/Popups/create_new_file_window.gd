class_name CreateFileWindow
extends Window

@export_file var WARNING_POPUP = "res://scenes/Popups/warning_popup.tscn"
@export_file var FILE_DIALOG = "res://scenes/Project_System/open_project_dialog.tscn"
const NO_NAME_WARN = "File must have a name."
const INVALID_PATH = "Provided path is invalid."

signal submitted(path : String)

var _file_name : String
var _file_path : String
var _selected_type : FileTypes.Types

@onready var _path_field : LineEdit = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/FilePath
@onready var type_option : OptionButton = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/OptionButton
@onready var _command_invoker : CommandInvoker = CommandInvoker.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(queue_free)

func set_selected_type(type : FileTypes.Types):
	var index = type_option.get_item_index(type)
	type_option.selected = index
	_selected_type = type

## Used to set the path field to where the location of where the window was created from the file system.
func set_path(path : String):
	_path_field.text = path
	_file_path = path

func file_ext_from_type() -> String:
	match _selected_type:
		FileTypes.Types.LEVEL:
			return FileIO.LEVEL_EXT
		FileTypes.Types.TEMPLATE:
			return FileIO.TEMPLATE_EXT
		FileTypes.Types.ENUM:
			return FileIO.ENUM_EXT
	return ".json"

func _on_cancel_pressed() -> void:
	queue_free()

func _on_save_pressed() -> void:
	## Call the command related to the file type being requested.
	if DirAccess.dir_exists_absolute(_file_path):
		if _file_name.length() > 0:
			var ext : String = file_ext_from_type()
			var path = "%s/%s%s" % [_file_path, _file_name, ext]
			match ext:
				FileIO.LEVEL_EXT:
					_command_invoker.set_command(NewLevelCommand.new(path)).execute_command()
				FileIO.TEMPLATE_EXT:
					_command_invoker.set_command(NewTemplateCommand.new(path)).execute_command()
				FileIO.ENUM_EXT:
					pass ## TODO: add the enum logic when ready...
			submitted.emit(path)
			queue_free()
		else:
			show_warning(NO_NAME_WARN)
	else:
		show_warning(INVALID_PATH)

func _on_file_path_text_submitted(_new_text: String) -> void:
	_on_save_pressed()

func _on_filename_text_submitted(_new_text: String) -> void:
	_on_save_pressed()

func _on_file_path_text_changed(new_text: String) -> void:
	_file_path = new_text

func _on_filename_text_changed(new_text: String) -> void:
	_file_name = new_text

func show_warning(message):
	var warning_popup : WarningPopup = load(WARNING_POPUP).instantiate()
	add_child(warning_popup)
	warning_popup.set_message(message)

func _on_option_button_item_selected(index: int) -> void:
	_selected_type = $"PanelContainer/MarginContainer/CenterContainer/VBoxContainer/OptionButton".get_item_id(index)


func _on_file_explorer_button_pressed() -> void:
	var dialog : OpenProjectDialog = load(FILE_DIALOG).instantiate()
	add_child(dialog)
	_file_path = await dialog.dir_selected
	$PanelContainer/MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/FilePath.text = _file_path
