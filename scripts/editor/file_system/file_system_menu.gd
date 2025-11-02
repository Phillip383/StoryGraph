extends PopupMenu

class_name FileContextMenu

const RENAME = 0
const CREATE_DIR = 1
const CREATE_LEVEL = 2
const CREATE_TEMPLATE = 3
const DELETE = 4



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(clear)

## Items for when a non-item is clicked.
func add_items():
	add_item("Create Directory", CREATE_DIR)
	add_item("Create Level", CREATE_LEVEL)
	add_item("Create Template", CREATE_TEMPLATE)

## Items for when a file or directory is clicked
func add_items_file_clicked():
	add_item("Rename", RENAME)
	add_item("Delete", DELETE)
