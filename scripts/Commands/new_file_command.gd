extends Command
class_name NewFileCommand

@export_file var NEW_FILE_WINDOW = "res://scenes/Popups/create_new_file.tscn"

signal file_created(path)

var _type : FileTypes.Types
var _path : String

## @param type - optional type to set as the seleted type for the spawned create file window.
## @param path - optional start path to set for the spawned create file window.
func _init(type : FileTypes.Types = FileTypes.Types.NONE, path : String = ""):
	_type = type
	_path = path

func execute() -> void:
	await spawn_window()

func spawn_window():
	var new_file_win : CreateFileWindow = load(NEW_FILE_WINDOW).instantiate()
	Engine.get_main_loop().root.add_child(new_file_win)
	new_file_win.set_path(_path)
	new_file_win.set_selected_type(_type)
	var path = await new_file_win.submitted
	file_created.emit(path)
