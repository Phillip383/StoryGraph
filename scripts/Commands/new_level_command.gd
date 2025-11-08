extends Command
class_name NewLevelCommand

@export_file var NEW_FILE_WINDOW = "res://scenes/Popups/create_new_file.tscn"

func _init() -> void:
	pass

func execute() -> void:
	var path = await open_new_level_window()
	var io = FileIO.new()
	io.create_file(path)
	## Add the level to the level's container.
	var scene_tree : SceneTree = Engine.get_main_loop()
	var level_container : LevelContainer = scene_tree.get_first_node_in_group("Level Container")
	level_container.create_new_level(path)

##Opens a new file window, awaits for submission and returns the path of the new file
func open_new_level_window():
	var win : CreateFileWindow = load(NEW_FILE_WINDOW).instantiate()
	var tree : SceneTree = Engine.get_main_loop()
	tree.root.add_child(win)
	win.set_selected_type(FileTypes.Types.LEVEL)
	return await win.submitted
