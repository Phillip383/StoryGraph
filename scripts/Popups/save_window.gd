extends Window

class_name SaveWindow

@export var WARNING_POPUP : PackedScene
const WARNING_EXISTS = "Level with name already exists."
const WARNING_NO_NAME = "Please Name The Level."

signal on_save(file_name : String, _type)

var _file_name : String
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
	if _file_name.length() > 0:
		## TODO: Add the ability for the save window to be context aware of what type of file we are saving when I add templates and other files.
		if not FileManager.file_exists(_file_name, _file_type):
			on_save.emit(_file_name, _file_type)
			queue_free()
		else:
			var warning_popup = WARNING_POPUP.instantiate()
			add_child(warning_popup)
			warning_popup.set_message(WARNING_EXISTS)
	else:
		var warning_popup = WARNING_POPUP.instantiate()
		add_child(warning_popup)
		warning_popup.set_message(WARNING_NO_NAME)

func _on_filename_text_submitted(_new_text: String) -> void:
	_on_save_pressed()
