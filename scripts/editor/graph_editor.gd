extends CanvasLayer


## TODO: need to link to the signal for add_node or delete node and set the ID on the node, or decrement it here upon deletion.
var _nodeID : int ## This will increment whenever a node is added or decrement on delete

## The path to the currently open project
var _current_project_dir := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OS.low_processor_usage_mode = true

func open_project(project_path : String) -> Error:
	##Already open
	if project_path == _current_project_dir:
		return ERR_ALREADY_IN_USE
	#if the project file is present.
	if FileAccess.file_exists(project_path + "/story.project"):
		_current_project_dir = project_path
		## Set the window name to the project directory name
		set_application_title()
		return OK
	return ERR_DOES_NOT_EXIST

## Returns the root directory for the currently open project.
func get_open_project():
	return _current_project_dir

## Returns the path of the levels directory
func get_levels_directory():
	return "%s/levels" % _current_project_dir

## Returns the path of the level object
func get_level_by_name(level_name : String):
	return "%s/levels/%s" % _current_project_dir % level_name

## Returns the path of the templates directory
func get_templates_directory():
	return "%s/templates" % _current_project_dir

## Returns the path of the story.project file
func get_project_file():
	return "%s/story.project" % _current_project_dir

##TODO: Open a level file by spawning a new graph window in the editor and load the level information into the graph.
func open_level_by_name(_level_name : String):
	pass

##TODO: Open the project file for editing
func open_project_file():
	pass

func set_application_title():
	var tokens = _current_project_dir.split("/")
	get_tree().root.title += " - Project - " + tokens[tokens.size() - 1]

func increment_node_id():
	_nodeID += 1

func decrement_node_id():
	_nodeID -= 1
