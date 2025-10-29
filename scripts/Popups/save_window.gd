extends Window

class_name SaveWindow

const WARNING_POPUP = preload("res://scenes/UI/Popups/warning_popup.tscn")
const WARNING_EXISTS = "Level with name already exists."
const WARNING_NO_NAME = "Please Name The Level."

signal on_save(file_name : String)

var _file_name : String

func _ready() -> void:
	close_requested.connect(queue_free)

func _on_filename_text_changed(new_text: String) -> void:
	_file_name = new_text

func _on_cancel_pressed() -> void:
	queue_free()

func _on_save_pressed() -> void:
	if _file_name.length() > 0: 
		if not FileAccess.file_exists(GraphEditor.get_levels_directory() + "/%s.json" % [_file_name]):
			on_save.emit(_file_name)
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
