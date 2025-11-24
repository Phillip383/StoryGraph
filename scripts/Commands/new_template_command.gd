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
	io.create_file(_path)
	io.save_file(_path, _data)
	GraphEditor.get_or_add_project_data(GraphEditor.TEMPLATE_KEY, _path)
	template_created.emit(_path)
