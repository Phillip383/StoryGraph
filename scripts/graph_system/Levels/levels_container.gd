extends InspectorContainer
class_name LevelContainer


@export var SAVE_NEW_WINDOW : PackedScene
const SAVE_WINDOW_TITLE = "Save Level"
@export var CLOSE_UNSAVED_PROMPT : PackedScene
@export var LEVEL_SCENE : PackedScene

signal on_level_changed(level : Level)
signal level_created(level : Level)
signal on_level_save(active_level : Level)
signal on_story_line_added(node : BaseStoryNode)
signal on_story_lines_removed(_names : Array[StringName])

## Invokes various commands, IE. Save/Undo/Redo for the currently active level.
@onready var command_invoker : CommandInvoker = CommandInvoker.new()
var _command : Command ## Free after command is completed and all signals have fired.

var _active_level : Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	tab_changed.connect(on_tab_switched)
	child_entered_tree.connect(on_child_added)
	FileManager.on_level_load_request.connect(load_level)
	FileManager.project_changed.connect(clear_levels)
	FileManager.level_renamed.connect(level_renamed)
	## Setup tabs for closing
	get_tab_bar().set_tab_close_display_policy(TabBar.CLOSE_BUTTON_SHOW_ALWAYS)
	get_tab_bar().tab_close_pressed.connect(on_tab_closed)

## Listen for command short cut actions.
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save") and _active_level:
		_command = SaveCommand.new(get_active_level())
		_command.save_complete.connect(on_saved)
		command_invoker.set_command(_command).execute_command()
	## TODO: Add the commands associated with the actions
	elif event.is_action_pressed("save_all"):
		pass
	elif event.is_action_pressed("undo"):
		pass
	elif event.is_action_pressed("redo"):
		pass
	elif event.is_action_pressed("new_level"):
		pass

func level_deleted(_name : StringName):
	_name = _name.get_slice(".", 0)
	for i in range(get_child_count()):
		var level = get_tab_control(i) as Level
		if level:
			var to_find_name = level.name.get_slice(".", 0)
			if to_find_name == _name:
				level.queue_free()

func level_renamed(_old_name : StringName, _new_name : StringName):
	for i in range(get_child_count()):
		var level = get_tab_control(i) as Level
		if level and level.name == _old_name:
			level.name = _new_name ## The signal in FileManager appends the file extension.
			set_tab_title(i, _new_name)

func clear_levels():
	for child in get_children():
		if child as Level:
			child.queue_free()

##TODO: Move most of this logic to a close command.
func on_tab_closed(tab : int):
	if get_child_count() == 1: ## Always need a level open.
		return
	var level : Level = get_tab_control(tab)
	if level.get_current_state() == GraphManager.GraphState.EDITING and FileIO.does_file_exist(level.get_resource_path(), level.name):
		var prompt = CLOSE_UNSAVED_PROMPT.instantiate()
		add_child(prompt)
		var selection = await prompt.on_selection
		if selection == true:
			var save_command : SaveCommand = SaveCommand.new(get_active_level())
			command_invoker.set_command(save_command).execute_command()
			level.queue_free()
	else:
		level.queue_free()

func get_active_level()-> Level:
	return _active_level

func on_tab_switched(_index : int):
	_active_level = get_tab_control(_index) as Level
	on_level_changed.emit(_active_level)

func connect_for_updates(level : Level):
		if level:
			if not level.on_edited.is_connected(_on_level_edited):
				level.on_edited.connect(_on_level_edited)
			if not on_level_changed.is_connected(level.on_level_changed):
				on_level_changed.connect(level.on_level_changed)

			level.on_story_line_added.connect(_story_line_added)
			level.on_story_lines_removed.connect(_story_lines_removed)

func on_child_added(child : Node):
	var level = child as Level
	if level:
		if not level.on_edited.is_connected(_on_level_edited):
			level.on_edited.connect(_on_level_edited)
		if not on_level_changed.is_connected(level.on_level_changed):
			on_level_changed.connect(level.on_level_changed)

## Creates a new level, sets it's resource path and name, and add's it to the level's container.
func create_new_level(_path : String, id : int):
	var new_level : Level = LEVEL_SCENE.instantiate()
	add_child(new_level)
	new_level.set_resource_path(_path)
	var new_level_name = _path.substr(_path.rfind("/") + 1) ## Get the name between the extension and directory.
	new_level_name = new_level_name.get_slice(".", 0)
	new_level.name = new_level_name
	new_level._level_id = id
	var new_level_index = get_tab_idx_from_control(new_level)
	current_tab = new_level_index
	set_tab_title(new_level_index, new_level_name)
	command_invoker.set_command(SaveCommand.new(new_level)).execute_command() ## Save with default data.
	level_created.emit(new_level)

# When the level is edited, we flag the title to illustrate unsaved work.
func _on_level_edited(level : Level):
	set_tab_title(get_tab_idx_from_control(level), level.name + "*")


func on_saved(context):
	on_level_save.emit(context)
	set_tab_title(get_tab_idx_from_control(context), context.name)
	_command = null

## TODO: Move to a load/open level command
func load_level(_data, path = ""):
	if !_data:
		return

	var level_name = get_level_name_from_path(path)
	if is_level_open(level_name):
		return

	var loaded_level : Level = LEVEL_SCENE.instantiate()
	add_child(loaded_level)
	_data["name"] = level_name
	loaded_level.load_level(_data)
	var level_idx = get_tab_idx_from_control(loaded_level)
	current_tab = level_idx
	set_tab_title(level_idx, loaded_level.name)
	connect_for_updates(loaded_level)
	loaded_level.set_resource_path(path)
	FileManager.post_level_load.emit(loaded_level)

func get_level_name_from_path(path : String) -> String:
	var level_name = path.substr(path.rfind("/") + 1)
	level_name = level_name.get_slice(".", 0)
	return level_name

func is_level_open(_name : StringName) -> bool:
	for i in range(get_child_count()):
		if get_tab_title(i) == _name:
			current_tab = i
			return true
	return false

func _story_line_added(node : BaseStoryNode):
	on_story_line_added.emit(node)

func _story_lines_removed(_names : Array[StringName]) -> void:
	on_story_lines_removed.emit(_names)


func _on_file_system_level_deleted(_name: String) -> void:
	level_deleted(_name)
