extends Window

class_name SaveWindow

@export var WARNING_POPUP : PackedScene
const WARNING_EXISTS = "Level with name already exists."
const WARNING_NO_NAME = "Please Name The Level."
const WARNING_INVALID_PATH = "Path does not exist."

signal on_save(path : String)

var _file_name : String
var _file_path : String
var _file_type : FileManager.FileType

func _ready() -> void:
	close_requested.connect(queue_free)

func set_file_type(_type : FileManager.FileType):
	_file_type = _type

func _on_filename_text_changed(new_text: String) -> void:
	_file_name = new_text

func _on_cancel_pressed() -> void:
	queue_free()

func _on_save_pressed() -> void:
	var valid_path = FileAccess.file_exists(_file_path)
	if not valid_path:
		show_warning(WARNING_INVALID_PATH)
	if _file_name.length() > 0 and valid_path:
		on_save.emit("%s/%s.json" % [_file_path, _file_name]) ## Emit the path...
	else:
		show_warning(WARNING_NO_NAME)

func show_warning(message : String):
	var warning_popup = WARNING_POPUP.instantiate()
	add_child(warning_popup)
	warning_popup.set_message(message)

## Allow for submission with press enter.
func _on_filename_text_submitted(_new_text: String) -> void:
	_on_save_pressed()

func _on_file_path_text_submitted(_new_text: String) -> void:
	_on_save_pressed()

func _on_file_path_text_changed(new_text: String) -> void:
	_file_path = new_text
