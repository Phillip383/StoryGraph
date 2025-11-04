extends PanelContainer

class_name LevelThumbnail

## SIGNALS

signal thumbnail_menu_requested(thumbnail)
signal thumbnail_hover_end()
signal file_renamed(_name : StringName)

## The path to the file this thumbnail represents.
var _resource_path : String
var _active : bool = false

@onready var _name_label : LineEdit = $HBox/Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	_name_label.focus_exited.connect(_rename_canceled)
	_name_label.gui_input.connect(_gui_input)

func _process(_delta: float) -> void:
	turn_off_menu()

func set_thumbnail_name(_name : String):
	_name_label.text = _name

func get_resource_path():
	return _resource_path

func set_resource_path(_path : String):
	_resource_path = _path

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click and event.button_index != MOUSE_BUTTON_RIGHT:
		var status = []
		FileManager.load_file_by_name(_name_label.text, FileManager.FileType.LEVEL, status)
		assert(status[0] == OK, "Level failed to load from thumbnail. :: Error: " + error_string(status[0]))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		show_menu()

	if event.is_action_pressed("ui_cancel"):
		_rename_canceled()

func _on_mouse_entered():
	selected()

func show_menu():
	selected()
	thumbnail_menu_requested.emit(self)

func on_menu_selection(id : int, thumbnail):
	match id:
		FileOptions.RENAME:
			thumbnail._rename_active()
		FileOptions.DELETE:
			thumbnail._delete_file()

func turn_off_menu():
	if not _active:
		return
	var mouse_pos = get_global_mouse_position()
	var rect = get_global_rect()
	if not rect.has_point(mouse_pos):
		deselect()
		thumbnail_hover_end.emit()

func selected():
	_active = true
	var style = get_theme_stylebox("Hover")
	add_theme_stylebox_override("panel", style)

func deselect():
	_active = false
	var style = get_theme_stylebox("Panel")
	add_theme_stylebox_override("panel", style)

func _rename_active():
	_name_label.editable = true
	_name_label.select_all()
	_name_label.grab_focus()

func _rename_canceled():
	release_focus()
	_name_label.editable = false

func _rename_file(_new_name : StringName):
	_name_label.editable = false
	FileManager.rename_file(_resource_path, _new_name, FileManager.FileType.LEVEL)
	file_renamed.emit(_new_name)

func _delete_file():
	FileManager.delete_file(_resource_path, FileManager.FileType.LEVEL)
	queue_free()

func _on_name_text_submitted(new_text: String) -> void:
	if not FileManager.file_exists(new_text, FileManager.FileType.LEVEL):
		_rename_file(new_text)
