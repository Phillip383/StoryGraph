extends Command
class_name DeleteFileCommand

signal delete_complete(file_name)

var _path : String

func _init(path : String) -> void:
	_path = path

func execute() -> void:
	var io : FileIO = FileIO.new()
	var file_name = io.delete_file(_path)
	delete_complete.emit(file_name)
