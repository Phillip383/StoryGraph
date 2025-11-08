extends Command
class_name OpenFileCommand

var _file_path : String

func _init(file_path : String) -> void:
    _file_path = file_path

func execute() -> void:
    open_file()

func open_file():
    var io : FileIO = FileIO.new()
    io.open_file(_file_path)