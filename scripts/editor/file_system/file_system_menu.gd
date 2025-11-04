extends PopupMenu

class_name FileContextMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visibility_changed.connect(clear)

## Items for when a non-item is clicked.
func add_items():
	add_item("Create Directory", FileOptions.CREATE_DIR)
	add_item("Create Level", FileOptions.CREATE_LEVEL)
	add_item("Create Template", FileOptions.CREATE_TEMPLATE)

## Items for when a file or directory is clicked
func add_items_file_clicked():
	add_item("Rename", FileOptions.RENAME)
	add_item("Delete", FileOptions.DELETE)
