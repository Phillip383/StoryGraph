extends Command
class_name NewDirectoryCommand

var _path : String

func _init(path : String) -> void:
	_path = path

func execute() -> void:
	create_directory()

func create_directory():
	DirAccess.make_dir_recursive_absolute(_path)
