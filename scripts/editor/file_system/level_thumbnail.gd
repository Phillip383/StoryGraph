extends ThumbnailBase

class_name LevelThumbnail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func _process(_delta: float) -> void:
	super._process(_delta)

func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseButton and event.double_click and event.button_index != MOUSE_BUTTON_RIGHT:
		var status = []
		FileManager.load_file_by_name(_name_label.text, FileManager.FileType.LEVEL, status)
		assert(status[0] == OK, "Level failed to load from thumbnail. :: Error: " + error_string(status[0]))
