extends PanelContainer
class_name ThumbnailBase

signal thumbnail_menu_requested(thumbnail)
signal thumbnail_hover_end()
signal thumbnail_deleted(_resource_path)

## The path to the file this thumbnail represents.
var _resource_path : String
var _active : bool = false
var _is_menu_open : bool = false

@onready var _name_label : LineEdit = $HBox/Name
@onready var command_invoker : CommandInvoker = CommandInvoker.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_name_label.focus_exited.connect(_rename_canceled)
	_name_label.gui_input.connect(_gui_input)
	_name_label.text_submitted.connect(_on_name_text_submitted)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if _is_menu_open:
		turn_off_menu()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		show_menu()

	if event.is_action_pressed("ui_cancel"):
		_rename_canceled()

func get_thumbnail_name():
	return _name_label.text

func set_thumbnail_name(_name : String):
	_name_label.text = _name.get_slice(".", 0) ## Name without extension

func get_resource_path():
	return _resource_path

func set_resource_path(_path : String):
	_resource_path = _path

func _on_mouse_entered():
	selected()

func _on_mouse_exited():
	if not _is_menu_open:
		deselect()

func show_menu():
	selected()
	_is_menu_open = true
	thumbnail_menu_requested.emit(self)

func on_menu_selection(id : int, _thumbnail):
	if not _active:
		return
	match id:
		FileOptions.RENAME:
			_rename_active()
		FileOptions.DELETE:
			_delete_file()

func turn_off_menu():
	var mouse_pos = get_global_mouse_position()
	var rect = get_global_rect()
	if not rect.has_point(mouse_pos):
		deselect()
		_is_menu_open = false
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

func _rename_file(_new_name : StringName):
	_name_label.editable = false
	var rename_command : RenameCommand = RenameCommand.new(_resource_path, _new_name)
	command_invoker.set_command(rename_command).execute_command()

func _delete_file():
	var delete_command : DeleteFileCommand = DeleteFileCommand.new(_resource_path)
	command_invoker.set_command(delete_command).execute_command()
	thumbnail_deleted.emit(_resource_path)
	queue_free()

func _rename_canceled():
	release_focus()
	_name_label.editable = false

func _on_name_text_submitted(new_text: String) -> void:
	if not FileIO.does_file_exist(_resource_path, new_text):
		_rename_file(new_text)

func _get_drag_data(at_position: Vector2) -> Variant:
	var drag_preview = self.duplicate()
	drag_preview.deselect()
	set_drag_preview(drag_preview)
	return self
