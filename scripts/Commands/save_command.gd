class_name SaveCommand
extends Command

## Emitted when the save operation is completed, passes the context for the operation.
signal save_complete(context)

var _context : Variant

func _init(content : Variant) -> void:
	_context = content

func execute() -> void:
	save()
	save_complete.emit(_context)

func save():
	var io : FileIO = FileIO.new()
	var data = _context.save()
	io.save_file(_context.get_resource_path(), data)
