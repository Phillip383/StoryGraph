extends PanelContainer

class_name LevelThumbnail


## Emitted when the thumbnail is clicked.
signal file_menu_request(file : Node)

@export var hover_box : StyleBox
@export var normal_box : StyleBox

@onready var _name_label : Label = $HBox/Name

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(on_hovered)
	mouse_exited.connect(on_hover_end)
	var request_func : Callable = get_tree().get_first_node_in_group("File System").file_menu_request
	file_menu_request.connect(request_func)

func set_thumbnail_name(_name : String):
	_name_label.text = _name

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.double_click:
		var status = []
		FileManager.load_file_by_name(_name_label.text, FileManager.FileType.LEVEL, status)
		assert(status[0] == OK, "Level failed to load from thumbnail. :: Error: " + error_string(status[0]))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		file_menu_request.emit(self)

func on_hovered():
	add_theme_stylebox_override("panel", hover_box)

func on_hover_end():
	add_theme_stylebox_override("panel", normal_box)
