extends Command
class_name RenameCommand

signal rename_complete(new_path)

var _file_path : String
var _to_name : String

func _init(file_path : String, to_name : String):
	_file_path = file_path
	_to_name = to_name

func execute() -> void:
	var new_path = FileIO.rename_file(_file_path, _to_name)
	rename_complete.emit(new_path)
