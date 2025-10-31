extends PanelContainer

class_name ProjectListElement

signal on_selection(_project_path : String)

@onready var icon : TextureRect = $HBoxContainer/MarginContainer/Icon
@onready var project_name : Label = $HBoxContainer/Name

var _project_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_icon(_texture : Texture2D):
	icon.texture = _texture

func set_project_name(_text : String):
	project_name.text = _text

func set_project_path(_path : String):
	_project_path = _path

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		on_selection.emit(_project_path)
