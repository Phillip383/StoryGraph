extends PanelContainer

class_name LevelThumbnail


@export var hover_box : StyleBox
@export var normal_box : StyleBox

## The path to the file this thumbnail represents.
var _resource_path : String

@onready var _name_label : Label = $HBox/Name
@onready var menu : FileContextMenu = $FileSystemMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(on_hovered)
	mouse_exited.connect(on_hover_end)
	menu.id_pressed.connect(_on_menu_item_selected)

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

func show_menu():
	selected()
	menu.position = get_viewport().get_mouse_position()
	menu.visible = true
	menu.add_items_file_clicked()

func on_hovered():
	selected()

func on_hover_end():
	if menu.visible == false:
		deselect()

func turn_off_menu():
	var mouse_pos = get_global_mouse_position()
	var rect = get_global_rect()
	if not rect.has_point(mouse_pos):
		menu.visible = false
		deselect()

func selected():
	add_theme_stylebox_override("panel", hover_box)

func deselect():
	add_theme_stylebox_override("panel", normal_box)

func _on_menu_item_selected(id : int):
	match id:
		FileOptions.RENAME:
			_rename_file()
		FileOptions.DELETE:
			_delete_file()


func _rename_file():
	##TODO: Make the label editable to get the name, once it's submitted, set it.
	FileManager.rename_file(_resource_path, "Dragon.level", FileManager.FileType.LEVEL)

func _delete_file():
	FileManager.delete_file(_resource_path, FileManager.FileType.LEVEL)
	queue_free()
