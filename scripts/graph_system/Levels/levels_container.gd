extends InspectorContainer


@export var SAVE_NEW_WINDOW : PackedScene
const SAVE_WINDOW_TITLE = "Save Level"
@export var CLOSE_UNSAVED_PROMPT : PackedScene
@export var LEVEL_SCENE : PackedScene

signal on_level_changed(level : Level)
signal on_level_save(active_level : Level)

var _active_level : Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	tab_changed.connect(on_tab_switched)
	child_entered_tree.connect(on_child_added)
	_active_level = get_tab_control(0) as Level
	FileManager.level_create_requested.connect(create_new_level)
	FileManager.save_focused_requested.connect(save_request)
	FileManager.on_level_load_request.connect(load_level)
	connect_for_updates()

	## Setup tabs for closing
	get_tab_bar().set_tab_close_display_policy(TabBar.CLOSE_BUTTON_SHOW_ALWAYS)
	get_tab_bar().tab_close_pressed.connect(on_tab_closed)


func on_tab_closed(tab : int):
	if get_child_count() == 1: ## Always need a level open.
		return
	var level = get_tab_control(tab)
	if level.get_current_state() == GraphManager.GraphState.EDITING and FileManager.file_exists(level.name, FileManager.FileType.LEVEL):
		var prompt = CLOSE_UNSAVED_PROMPT.instantiate()
		add_child(prompt)
		var selection = await prompt.on_selection
		if selection == true:
			save(level.name, FileManager.FileType.LEVEL)
			level.queue_free()
	elif level.get_current_state() == GraphManager.GraphState.EDITING:
		await new_save(FileManager.FileType.LEVEL)
		level.queue_free()
	else:
		level.queue_free()

func get_active_level()-> Level:
	return _active_level

func on_tab_switched(_index : int):
	_active_level = get_tab_control(_index) as Level
	on_level_changed.emit(_active_level)

func connect_for_updates():
	for child in get_children():
		var level = child as Level
		if level:
			if not level.on_edited.is_connected(_on_level_edited):
				level.on_edited.connect(_on_level_edited)
			if not on_level_changed.is_connected(level.on_level_changed):
				on_level_changed.connect(level.on_level_changed)

func on_child_added(child : Node):
	var level = child as Level
	if level:
		if not level.on_edited.is_connected(_on_level_edited):
			level.on_edited.connect(_on_level_edited)
		if not on_level_changed.is_connected(level.on_level_changed):
			on_level_changed.connect(level.on_level_changed)

func create_new_level():
	var new_level = LEVEL_SCENE.instantiate()
	add_child(new_level)

func _on_menu_bar_new_level_request() -> void:
	create_new_level()

# When the level is edited, we flag the title to illustrate unsaved work.
func _on_level_edited(level : Level):
	set_tab_title(get_tab_idx_from_control(level), level.name + "*")

## Connected signal from the FileManager, if the requested save type is of LEVEL, the save the active level.
func save_request(_type):
	if _type == FileManager.FileType.LEVEL:
		## Prompt a save window to name the level if there is no name.
		if _active_level.name == _active_level.DEFAULT_NAME:
			await new_save(_type) ## Await the save window confirmation
		else:
			save(_active_level.name, _type)

## Prompt the user to name the level if it hasn't been named yet. 
func new_save(_type):
	var save_window : SaveWindow = SAVE_NEW_WINDOW.instantiate()
	save_window.title = SAVE_WINDOW_TITLE
	save_window.set_file_type(_type)
	add_child(save_window)
	save_window.on_save.connect(save, _type)
	await save_window.on_save

## Saves the active level in the tab container.
#@param: _file_name, either passed by the tab containers existing active level name, or by the save prompt window if the name is default.
#@param: _type, the type of file needing to be saved.
#@return: Returns an Error code.
##
func save(_file_name, _type):
	var _level_data = _active_level.save_level(_file_name)
	on_level_save.emit(_active_level)
	var error = FileManager.save_file(_file_name, _type, _level_data)
	if error == OK:
		## Set the title bar back to a saved state.
		set_tab_title(get_tab_idx_from_control(_active_level), _active_level.name)
	return error

func load_level(_data):
	var loaded_level : Level = LEVEL_SCENE.instantiate()
	add_child(loaded_level)
	loaded_level.load_level(_data)
	FileManager.post_level_load.emit(loaded_level)
