extends Command
class_name NewTemplateCommand

signal template_created(path)

var _data : Dictionary
var _path : String

## @Param: data, optional data to inilize the template with
func _init(path : String, data : Dictionary = {}):
	_path = path
	_data = data


func execute() -> void:
	create_template()


func create_template() -> void:
	var io = FileIO.new()
	## if data is empty, store something so the json parse doesn't fail.
	if _data.is_empty():
		_data["empty"] = {} ## TODO: Fix this in save file, gracefully handle null data there
	io.create_file(_path)
	io.save_file(_path, _data)
	template_created.emit(_path)
