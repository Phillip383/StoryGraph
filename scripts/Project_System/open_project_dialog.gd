extends FileDialog

class_name OpenProjectDialog

@export var WARNING_POPUP : PackedScene

## Emitted when a valid project is selected to open
signal on_successful_selection(project : Dictionary[String, String])

## Cached path that is selected, this is a funky thing, but the design of the file dialog dictates it necessary to implement the get_ok_button pressed signal to keep the file dialog opened if an invalid path is selected.
var path

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_ok_button().pressed.connect(_on_ok_button_pressed)
	dir_selected.connect(on_select_directory)

func on_select_directory(dir_path : String):
	path = dir_path

func _on_ok_button_pressed():
	var tokens = path.split("/")
	var proj_name : String = tokens[tokens.size() - 1]
	var dict : Dictionary[String, String] = {proj_name : path}
	on_successful_selection.emit(dict)
