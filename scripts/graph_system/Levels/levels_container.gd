extends InspectorContainer

const SAVE_NEW_WINDOW = preload("res://scenes/UI/Popups/save_window.tscn")
const SAVE_WINDOW_TITLE = "Save Level"
const LEVEL_SCENE = preload("res://scenes/UI/Graph/level.tscn")

signal on_level_changed(level : Level)

var _active_level : Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	tab_changed.connect(on_tab_switched)
	child_entered_tree.connect(on_child_added)
	_active_level = get_tab_control(0) as Level
	FileManager.level_create_requested.connect(create_new_level)
	FileManager.save_focused_requested.connect(save_request)
	connect_for_updates()

func get_active_level()-> Level:
	return _active_level

func on_tab_switched(_index : int):
	_active_level = get_tab_control(_index) as Level
	on_level_changed.emit(_active_level)

func child_name_changed(level : Level):
	var _index = get_tab_idx_from_control(level)
	set_tab_title(_index, level.name)

func child_changed():
	var _index = get_tab_idx_from_control(_active_level)
	set_tab_title(_index, get_tab_title(_index) + "*")

func connect_for_updates():
	for child in get_children():
		var level = child as Level
		if level:
			level.level_name_change.connect(child_name_changed)
			level.on_changed.connect(child_changed)

func on_child_added(child : Node):
	var level = child as Level
	if level:
		level.level_name_change.connect(child_name_changed)
		level.on_changed.connect(child_changed)

func create_new_level():
	var new_level = LEVEL_SCENE.instantiate()
	add_child(new_level)

func _on_menu_bar_new_level_request() -> void:
	create_new_level()

"""
Connected signal from the Filemanager, if the requested save type is of LEVEL, the save the active level.
"""
func save_request(_type):
	if _type == FileManager.FileType.LEVEL:
		## Prompt a save window to name the level if their is no name.
		if _active_level.name == _active_level.DEFAULT_NAME:
			var save_window : SaveWindow = SAVE_NEW_WINDOW.instantiate()
			save_window.title = SAVE_WINDOW_TITLE
			save_window.set_file_type(_type)
			add_child(save_window)
			save_window.on_save.connect(_active_level.save_level)
		else:
			_active_level.save_level()
