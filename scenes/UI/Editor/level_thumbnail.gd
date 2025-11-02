extends VBoxContainer

class_name LevelThumbnail

@onready var _name_label : Label = $Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_thumbnail_name(_name : String):
	_name_label.text = _name
