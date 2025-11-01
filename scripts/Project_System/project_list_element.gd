extends PanelContainer

class_name ProjectListElement

signal on_selection(_project_path : String)

@onready var icon : TextureRect = $HBoxContainer/MarginContainer/Icon
@onready var project_name : Label = $HBoxContainer/Name

var _project_path : String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(show_hover)
	mouse_exited.connect(hide_hover)

func set_icon(_texture : Texture2D):
	icon.texture = _texture

func set_project_name(_text : String):
	project_name.text = _text

func set_project_path(_path : String):
	_project_path = _path

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.double_click:
		on_selection.emit(_project_path)

func _on_delete_pressed() -> void:
	GraphEditor.remove_project_from_list(project_name.text)
	queue_free()

func _on_rename_pressed() -> void:
	## TODO: Add rename feature
	pass # Replace with function body.

func show_hover():
	var style : StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = "#63858a33"
	style.border_color = "#6769f3ff"
	style.set_border_width_all(4)
	add_theme_stylebox_override("panel", style)

func hide_hover():
	remove_theme_stylebox_override("panel")
