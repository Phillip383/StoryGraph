class_name FileIO
extends RefCounted

@export_file var SAVE_WINDOW : String = "res://scenes/Popups/save_window.tscn"

static var LEVEL_EXT = ".level"
static var TEMPLATE_EXT = ".template"
static var ENUM_EXT = ".enum"

## Renames a file
#@param: path - the path to the file needing to be renamed.
#@param: to_name - the new name
static func rename_file(path : String, to_name : String) -> String:
	var ext = path.get_extension()
	var dir_name = to_name
	var file_name : StringName = "%s.%s" % [to_name, ext]
	to_name = file_name if not ext.is_empty() else dir_name
	var new_path = path.substr(0, path.rfind("/") + 1) + to_name
	DirAccess.rename_absolute(path, new_path)
	return new_path

func create_file(path : String):
	var file = FileAccess.open(path, FileAccess.WRITE)
	var err = FileAccess.get_open_error()
	assert(err == OK, "File Creation Failed:: " + error_string(err))
	file.close()
	GraphEditor.file_added.emit(path)

func open_file(path : String):
	if FileAccess.get_file_as_string(path).is_empty():
		return

	var ext = ".%s" % path.get_extension()
	var data = JSON.parse_string(FileAccess.get_file_as_string(path))
	match ext:
		LEVEL_EXT:
			_open_level(data, path)
		TEMPLATE_EXT:
			_open_template(data, path)
		ENUM_EXT:
			_open_enum(data, path)
		".json":
			pass

func _open_level(data, path):
	var scene_tree : SceneTree = Engine.get_main_loop()
	var level_container : LevelContainer = scene_tree.get_first_node_in_group("Level Container")
	level_container.load_level(data, path)

func _open_template(data, path):
	pass

func _open_enum(data, path):
	pass

func save_file(path : String, data : Variant):
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(JSON.stringify(data))
		file.close()
	else:
		save_file(await show_save_window(), "")

func delete_file(path : String):
	pass

func move_file(path : String):
	pass


## Returns the path entered in the save window.
func show_save_window() -> String:
	var save_window : SaveWindow = load(SAVE_WINDOW).instantiate()
	Engine.get_main_loop().add_child(save_window)
	return await save_window.on_save
