extends Window

class_name SaveWindow

signal on_save(file_name : String)

var _file_name : String

func _ready() -> void:
	close_requested.connect(queue_free)

func _on_filename_text_changed(new_text: String) -> void:
	_file_name = new_text

func _on_cancel_pressed() -> void:
	queue_free()

func _on_save_pressed() -> void:
	##TODO: Add validation, ensure the name is not a duplicate.
	on_save.emit(_file_name)
	queue_free()
