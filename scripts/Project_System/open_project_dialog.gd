extends FileDialog

class_name OpenProjectDialog

const WARNING_POPUP = preload("res://scenes/UI/Popups/warning_popup.tscn")

## Emitted when a valid project is selected to open
signal on_successful_selection(project_path)

## Cached path that is selected, this is a funky thing, but the design of the file dialog dictates it necessary to implement the get_ok_button pressed signal to keep the file dialog opened if an invalid path is selected.
var path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_ok_button().pressed.connect(_on_ok_button_pressed)
	dir_selected.connect(on_select_directory)

func on_select_directory(dir_path : String):
	path = dir_path

func _on_ok_button_pressed():
	var _error = FileManager.open_project(path)
	if _error == OK:
		on_successful_selection.emit(path)
		queue_free()
	else:
		show()
		var warning_popup : WarningPopup = WARNING_POPUP.instantiate()
		add_child(warning_popup)
		warning_popup.set_message(error_string(_error))
