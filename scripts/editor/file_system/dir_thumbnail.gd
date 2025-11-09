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
	super._gui_input(event)
	if event is InputEventMouseButton and event.double_click:
		directory_selected.emit(_resource_path)

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	return true

##TODO: Probably do need to pass the whole thumbnail so I can update the resource path on move and destroy the old thumbnail.
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var dragged_thumbnail = data as ThumbnailBase
	var move_to = _resource_path + "/" + dragged_thumbnail.get_resource_path().substr(dragged_thumbnail.get_resource_path().rfind("/") + 1)
	FileIO.move_file(dragged_thumbnail.get_resource_path(), move_to)
	dragged_thumbnail.queue_free()

func name_new_dir() -> String:
	_name_label.editable = true
	_name_label.grab_focus()
	_name_label.select_all()
	return await _name_label.text_submitted
