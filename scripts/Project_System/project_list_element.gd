extends PanelContainer

class_name ProjectListElement

signal on_selection(_project_path : String)

@onready var icon : TextureRect = $HBoxContainer/MarginContainer/Icon
@onready var project_name : Label = $HBoxContainer/Name

var _project_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_stylebox_override("panel", get_theme_stylebox("Panel"))
	mouse_entered.connect(show_hover)
	mouse_exited.connect(hide_hover)

func set_icon(_texture : Texture2D):
	icon.texture = _texture

func set_project_name(_text : String):
	project_name.text = _text

func get_project_name():
	return project_name.text

func set_project_path(_path : String):
	_project_path = _path

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		on_selection.emit(_project_path)

func _on_delete_pressed() -> void:
	GraphEditor.remove_project_from_list(project_name.text)
	queue_free()

func show_hover():
	add_theme_stylebox_override("panel", get_theme_stylebox("Hover"))

func hide_hover():
	add_theme_stylebox_override("panel", get_theme_stylebox("Panel"))
