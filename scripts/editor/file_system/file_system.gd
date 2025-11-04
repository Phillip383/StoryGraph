extends PanelContainer

const ROOT_NAME : String = "Content"

@export_file var level_thumbnail

## SIGNALS

signal menu_selection(id : int, thumbnail)
signal clear_thumbnail_focus()

@onready var tree : Tree = $MarginContainer/HSplitContainer/ScrollContainer/Tree
@onready var grid : GridContainer = $MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/MarginContainer2/ScrollContainer/GridContainer
@onready var menu : FileContextMenu = $FileSystemMenu

var _project_directory_path : String
var _project_directory : DirAccess

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FileManager.project_changed.connect(on_project_directory_changed)
	tree.item_selected.connect(on_item_selected)
	menu.id_pressed.connect(on_menu_item_selected)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT:
		show_menu()
	if event is InputEventMouseButton:
		clear_thumbnail_focus.emit()

func show_menu():
	var mouse_pos = get_viewport().get_mouse_position()
	menu.position = mouse_pos
	menu.visible = true
	menu.add_items()

func show_thumbnail_menu(thumbnail):
	var mouse_pos = get_viewport().get_mouse_position()
	menu.position = mouse_pos
	menu.visible = true
	menu.add_items_file_clicked()
	var id = await menu.id_pressed
	menu_selection.emit(id, thumbnail)

func destory_thumbnail_menu():
	menu.visible = false

func open_project_directory() -> DirAccess:
	_project_directory_path = FileManager.get_current_project_dir()
	return DirAccess.open(_project_directory_path)

## Creates the root item of the file tree.
func create_root() -> TreeItem:
	var root_item : TreeItem = tree.create_item()
	root_item.set_text(0, ROOT_NAME)
	return root_item

func create_dir(parent : TreeItem, item_name : StringName) -> TreeItem:
	var dir : DirAccess = DirAccess.open(_project_directory_path + "/" + item_name)
	var new_dir : TreeItem = parent.create_child()

	new_dir.set_text(0, item_name)
	## TODO: Set Directory Icon

	var dirs : PackedStringArray = dir.get_directories()
	for dir_name in dirs:
		create_dir(new_dir, dir_name) ## Recurse any nested directories...
	return new_dir

func create_file(parent : TreeItem, item_name: StringName) -> TreeItem:
	var new_item : TreeItem = parent.create_child()
	new_item.set_text(0, item_name)
	## TODO: Set File Icon
	return new_item

## Create a tree list of the project root directory.
func create_tree() -> void:
	_project_directory = open_project_directory()
	assert(DirAccess.get_open_error() == OK,
		   "Open Project Failure: " + error_string(DirAccess.get_open_error()))
	var _root_item : TreeItem = create_root()
	var _dirs : PackedStringArray = _project_directory.get_directories()
	for dir in _dirs:
		create_dir(_root_item, dir)


## Create thumbnails of directories and files within the grid container based on the active directory.
func create_thumbnails() -> void:
	clear_thumbnails()
	var selected_dir_path = _project_directory_path + "/" + tree.get_selected().get_text(0)
	var files = DirAccess.get_files_at(selected_dir_path)
	for file in files:
		var thumbnail : LevelThumbnail = load(level_thumbnail).instantiate()
		grid.add_child(thumbnail)
		connect_thumbnail(thumbnail, file, selected_dir_path)

func on_item_selected() -> void:
		create_thumbnails()

func on_menu_item_selected(id : int):
	match id:
		FileOptions.CREATE_TEMPLATE:
			_create_template()
		FileOptions.CREATE_DIR:
			_create_directory()
		FileOptions.CREATE_LEVEL:
			_create_level()

func _create_template():
	pass

func _create_directory():
	pass

func _create_level():
	pass

func clear_thumbnails() -> void:
	for thumbnail in grid.get_children():
		thumbnail.queue_free()


func on_project_directory_changed() -> void:
	tree.clear()
	clear_thumbnails()
	create_tree()


func on_directory_added() -> void:
	pass


func on_file_added() -> void:
	pass


func on_directory_removed() -> void:
	pass


func on_file_removed() -> void:
	pass

## Connects various signals for to handle actions on the thumbnails
func connect_thumbnail(thumbnail, file, path):
	thumbnail.set_thumbnail_name(file)
	thumbnail.set_resource_path(path + "/" + file)
	thumbnail.thumbnail_menu_requested.connect(show_thumbnail_menu)
	thumbnail.thumbnail_hover_end.connect(destory_thumbnail_menu)
	menu_selection.connect(thumbnail.on_menu_selection)
	clear_thumbnail_focus.connect(thumbnail._rename_canceled)

