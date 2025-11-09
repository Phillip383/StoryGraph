extends ThumbnailBase

class_name DirThumbnail

signal directory_selected(_resource_path)
signal directory_moved(from : String, to : String) ## Emitted when a directory is moved so the tree can be rebuilt...

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)

func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseButton and event.double_click:
		directory_selected.emit(_resource_path)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if data == self:
		return false
	return true


func _drop_data(at_position: Vector2, data: Variant) -> void:
	var dragged_thumbnail = data
	var move_to = _resource_path + "/" + dragged_thumbnail.get_resource_path().substr(dragged_thumbnail.get_resource_path().rfind("/") + 1)
	FileIO.move_file(dragged_thumbnail.get_resource_path(), move_to)
	if dragged_thumbnail.has_method("name_new_dir"):
		directory_moved.emit(dragged_thumbnail.get_resource_path(), move_to)
	dragged_thumbnail.queue_free()

func name_new_dir() -> String:
	_name_label.editable = true
	_name_label.grab_focus()
	_name_label.select_all()
	return await _name_label.text_submitted
