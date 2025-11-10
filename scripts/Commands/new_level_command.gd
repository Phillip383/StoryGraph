extends Command
class_name NewLevelCommand

signal creation_completed(path)

var _path : String

func _init(path : String) -> void:
	_path = path

func execute() -> void:
	var io = FileIO.new()
	io.create_file(_path)
	## Add the level to the level's container.
	var scene_tree : SceneTree = Engine.get_main_loop()
	var level_container : LevelContainer = scene_tree.get_first_node_in_group("Level Container")
	level_container.create_new_level(_path)
	creation_completed.emit(_path)
