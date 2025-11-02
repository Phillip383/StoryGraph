extends VBoxContainer

class_name LevelThumbnail

@onready var _name_label : Label = $Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_thumbnail_name(_name : String):
	_name_label.text = _name

func _gui_input(event: InputEvent) -> void:
	## TODO: Handle hover event's
	## TODO: Open level on double click
	if event is InputEventMouseButton and event.double_click:
		var status = []
		FileManager.load_file_by_name(_name_label.text, FileManager.FileType.LEVEL, status)
		assert(status[0] == OK, "Level failed to load from thumbnail. :: Error: " + error_string(status[0]))
