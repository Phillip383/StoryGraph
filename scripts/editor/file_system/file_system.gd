extends PanelContainer

const ROOT_NAME : String = "Content"

@export_category("Tree Icon")
@export var tree_icon : Texture2D
@export var tree_icon_color : Color
@export_category("File Thumbnails")
@export_file var level_thumbnail
@export_file var template_thumbnail
@export var dir_thumbnail : PackedScene

## SIGNALS
signal menu_selection(id : int, thumbnail)
signal clear_thumbnail_focus()
signal level_deleted(_name : String)
signal enum_deleted(_name : String)
signal Template_deleted(_name : String)

@onready var tree : Tree = $MarginContainer/HSplitContainer/ScrollContainer/Tree
@onready var grid : GridContainer = $MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/MarginContainer2/ScrollContainer/GridContainer
@onready var menu : FileContextMenu = $FileSystemMenu
@onready var back_dir : Button = $MarginContainer/HSplitContainer/PanelContainer/VBoxContainer/MarginContainer3/BackDir

var _project_directory_path : String
var _project_directory : DirAccess
var root : TreeItem = null
var search_regex : RegEx

@onready var _command_invoker : CommandInvoker = CommandInvoker.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GraphEditor.project_changed.connect(on_project_directory_changed)
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
	_project_directory_path = GraphEditor.get_current_project_dir()
	return DirAccess.open(_project_directory_path)

func set_tree_icon(item : TreeItem):
	item.set_icon(0, tree_icon)
	item.set_icon_modulate(0, tree_icon_color)
	item.set_icon_max_width(0, 16)

## Creates the root item of the file tree.
func create_root() -> TreeItem:
	_project_directory = open_project_directory()
	var root_item : TreeItem = tree.create_item()
	root_item.set_text(0, ROOT_NAME)
	root_item.set_meta("abs_path", _project_directory_path)
	set_tree_icon(root_item)
	tree.hide_root = false
	return root_item

func create_tree_item(parent : TreeItem, item_name : StringName) -> TreeItem:
	var parent_path : String = parent.get_meta("abs_path")
	var dir : DirAccess = DirAccess.open(parent_path + "/" + item_name)
	var new_dir : TreeItem = parent.create_child()
	new_dir.set_meta("abs_path", parent_path + "/" + item_name)
	new_dir.set_text(0, item_name.substr(item_name.rfind("/") + 1, item_name.length()))
	set_tree_icon(new_dir)
	if dir:
		var dirs : PackedStringArray = dir.get_directories()
		for dir_name in dirs:
			create_tree_item(new_dir, dir_name) ## Recurse any nested directories...
	return new_dir

func create_file(parent : TreeItem, item_name: StringName) -> TreeItem:
	var new_item : TreeItem = parent.create_child()
	new_item.set_text(0, item_name)
	return new_item

## Create a tree list of the project root directory.
func create_tree() -> void:
	root = create_root()
	var dirs : PackedStringArray = _project_directory.get_directories()
	for directory in dirs:
		create_tree_item(root, directory)
	tree.set_selected(root, 0)

## Create thumbnails of directories and files within the grid container based on the active directory.
func create_thumbnails(selected_dir_path : String) -> void:
	clear_thumbnails()
	var files = DirAccess.get_files_at(selected_dir_path)
	for file in files:
		var ext = "." + file.get_extension()
		if ext == FileIO.LEVEL_EXT:
			create_file_thumbnail(selected_dir_path, file, level_thumbnail)
		elif ext == FileIO.TEMPLATE_EXT:
			create_file_thumbnail(selected_dir_path, file, template_thumbnail)

	for dir in DirAccess.get_directories_at(selected_dir_path):
		create_dir_thumbnail(selected_dir_path, dir)

func on_item_selected() -> void:
	var path = tree.get_selected().get_meta("abs_path")
	create_thumbnails(path)

func on_menu_item_selected(id : int):
	match id:
		FileOptions.CREATE_TEMPLATE:
			var file_name = await _create_file(FileTypes.Types.TEMPLATE)
			var selected_path = tree.get_selected().get_meta("abs_path")
			create_file_thumbnail(selected_path, file_name, template_thumbnail)
		FileOptions.CREATE_DIR:
			_create_directory()
		FileOptions.CREATE_LEVEL:
			await _create_file(FileTypes.Types.LEVEL)


func _create_directory():
	var path : String = tree.get_selected().get_meta("abs_path")
	var new_dir : DirThumbnail = create_dir_thumbnail(path, "New Folder")
	var new_dir_name = await new_dir.name_new_dir()
	on_directory_added(new_dir_name)
	path = path + "/%s" % new_dir_name
	new_dir.set_resource_path(path)
	_command_invoker.set_command(NewDirectoryCommand.new(path)).execute_command()

## Returns the name of the file created
func _create_file(type : FileTypes.Types) -> String:
	var selected_path : String = tree.get_selected().get_meta("abs_path")
	var new_file_command := NewFileCommand.new(type, selected_path)
	_command_invoker.set_command(new_file_command).execute_command()
	var path = await new_file_command.file_created
	return path.substr(path.rfind("/") + 1).get_slice(".", 0)


func clear_thumbnails() -> void:
	for thumbnail in grid.get_children():
		thumbnail.queue_free()


func on_project_directory_changed() -> void:
	clear_thumbnails()
	create_tree()


func on_directory_added(dir_name : StringName) -> void:
	## Add the tree element to the path.
	var parent = tree.get_selected()
	var abs_path = parent.get_meta("abs_path") + "/" + dir_name
	var new_dir : TreeItem = parent.create_child()
	new_dir.set_text(0, dir_name)
	new_dir.set_meta("abs_path", abs_path)

## Remove the directory from the tree
func on_thumbnail_removed(_resource_path : String) -> void:
	var tree_item = find_tree_item(root, _resource_path)
	if tree_item:
		tree_item.free()
	notify_delete(_resource_path)

func notify_delete(path : String):
	var _name = path.substr(path.rfind("/") + 1).get_slice(".", 0)
	var ext = "." + path.get_extension()
	match ext:
		FileIO.LEVEL_EXT:
			level_deleted.emit(_name)
		FileIO.ENUM_EXT:
			enum_deleted.emit(_name)
		FileIO.TEMPLATE_EXT:
			Template_deleted.emit(_name)
		".json":
			pass

## Connects various signals for to handle actions on the thumbnails
func connect_thumbnail(thumbnail):
	thumbnail.thumbnail_menu_requested.connect(show_thumbnail_menu)
	thumbnail.thumbnail_hover_end.connect(destory_thumbnail_menu)
	thumbnail.thumbnail_deleted.connect(on_thumbnail_removed)
	menu_selection.connect(thumbnail.on_menu_selection)
	clear_thumbnail_focus.connect(thumbnail._rename_canceled)

func create_file_thumbnail(selected_dir_path : String, file : String, type : String):
	if selected_dir_path != tree.get_selected().get_meta("abs_path"):
		return
	var thumbnail = load(type).instantiate()
	grid.add_child(thumbnail)
	thumbnail.set_thumbnail_name(file)
	thumbnail.set_resource_path(selected_dir_path + "/" + file)
	connect_thumbnail(thumbnail)

func create_level_thumbnail(selected_dir_path : String, file : String):
	if selected_dir_path != tree.get_selected().get_meta("abs_path"):
		return
	var thumbnail : LevelThumbnail = load(level_thumbnail).instantiate()
	grid.add_child(thumbnail)
	thumbnail.set_thumbnail_name(file)
	thumbnail.set_resource_path(selected_dir_path + "/" + file)
	connect_thumbnail(thumbnail)


func create_dir_thumbnail(selected_dir_path : String, _name : String) -> DirThumbnail:
	var new_dir : DirThumbnail = dir_thumbnail.instantiate()
	grid.add_child(new_dir)
	new_dir.set_thumbnail_name(_name)
	new_dir.set_resource_path(selected_dir_path + "/" + _name)
	new_dir.directory_selected.connect(_on_dir_thumbnail_opened)
	new_dir.directory_moved.connect(_on_directory_moved)
	connect_thumbnail(new_dir)
	return new_dir


func _on_dir_thumbnail_opened(_path : String):
	var selected_dir = find_tree_item(tree.get_root(), _path)
	if selected_dir != null:
		tree.set_selected(selected_dir, 0)
		_set_back_dir_button_enable(_path)
		tree.queue_redraw()

	create_thumbnails(_path)

func _on_directory_moved(from : String, to : String):
	update_tree(from, to)
	create_tree()

## Returns the directory at which the directory was moved to.
func update_tree(from : String, to : String) -> TreeItem:
	var from_item = find_tree_item(tree.get_root(), from)
	from_item.set_meta("abs_path", to)
	return find_tree_item(from_item, to)

func find_tree_item(item: TreeItem, dir_path : String) -> TreeItem:
	var current_child = item.get_first_child()
	while current_child:
		if current_child.get_meta("abs_path") == dir_path:
			return current_child

		var found_item = find_tree_item(current_child, dir_path)
		if found_item:
			return found_item

		current_child = current_child.get_next()

	return null

func does_thumbnail_exist(_name : String) -> bool:
	for thumbnail in grid.get_children():
		if thumbnail.get_thumbnail_name() == _name:
			return true
	return false

func _on_levels_level_created(level: Level) -> void:
	var lvl_name = level.get_resource_path().substr(level.get_resource_path().rfind("/") + 1)
	var path = level.get_resource_path().substr(0, level.get_resource_path().rfind("/"))
	create_level_thumbnail(path, lvl_name)


func _on_back_dir_pressed() -> void:
	var parent = tree.get_selected().get_parent()
	tree.set_selected(parent, 0)
	_set_back_dir_button_enable(parent.get_meta("abs_path"))
	tree.queue_redraw()

## Checks if the current directory has a parent directory and it's not the root directory, set's the back buttons disabled property.
func _set_back_dir_button_enable(path : String):
	if not path or path.length() == 0:
		back_dir.release_focus()
		back_dir.disabled = true
		return
	var parent_dir = path.substr(0, path.rfind("/") - 1)
	if DirAccess.dir_exists_absolute(parent_dir) or path != _project_directory_path:
		back_dir.disabled = false
	else:
		back_dir.release_focus()
		back_dir.disabled = true


func _on_search_text_changed(new_text: String) -> void:
	## Use a regex to search the current directory for matching names
	search_regex.compile("%s" % new_text.to_lower())
	var files = grid.get_children()
	for file in files:
		if search_regex.search_all(file.get_thumbnail_name().to_lower()):
			file.visible = true
		else:
			file.visible = false


func _on_search_focus_entered() -> void:
	if !search_regex:
		search_regex = RegEx.new()
