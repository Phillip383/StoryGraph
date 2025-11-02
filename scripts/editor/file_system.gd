extends PanelContainer

const ROOT_NAME : String = "Content"

@onready var tree : Tree = $MarginContainer/HSplitContainer/ScrollContainer/Tree
@onready var grid : GridContainer = $MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/MarginContainer2/GridContainer

var _project_directory_path : String
var _project_directory : DirAccess

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	FileManager.project_changed.connect(on_project_directory_changed)
	pass # Replace with function body.

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
	var files : PackedStringArray = dir.get_files()
	for file in files:
		var new_file : TreeItem = new_dir.create_child()
		new_file.set_text(0, file)
	new_dir.set_text(0, item_name)
	return new_dir

func create_file(parent : TreeItem, item_name: StringName) -> TreeItem:
	var new_item : TreeItem = parent.create_child()
	new_item.set_text(0, item_name)
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


## Create thubmnails of directories and files within the grid container based on the active directory.
func create_thumbnails() -> void:
	pass

func on_item_selected() -> void:
	pass

func on_project_directory_changed() -> void:
	tree.clear()
	create_tree()


func on_directory_added() -> void:
	pass


func on_file_added() -> void:
	pass


func on_directory_removed() -> void:
	pass


func on_file_removed() -> void:
	pass
