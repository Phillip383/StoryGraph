extends ThumbnailBase

class_name DirThumbnail

signal directory_selected(_resource_path)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click:
		directory_selected.emit(_resource_path)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	if _can_drop_data(at_position, data):
		var move_to = _resource_path + data._resource_path.substr(data._resource_path.size(), data._resource_path.rfind("/"))
		FileManager.move_file(data._resource_path, move_to)

func name_new_dir() -> String:
	_name_label.editable = true
	_name_label.grab_focus()
	_name_label.select_all()
	return await _name_label.text_submitted
