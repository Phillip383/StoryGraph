extends Command
class_name ExportCommand

const EXPORT_LEVEL_DIR = "/levels"
const EXPORT_ENUM_DIR = "/enums"

##EXPORT_KEYS TODO: Make these customizable for the user's needs.
var NODE_KEY_NAME = "Quests" ## The name for the nodes the level contains.

var _export_type : ExportTypes.Types
var _export_path : String

func _init(export_type : ExportTypes.Types, export_path : String) -> void:
	_export_type = export_type
	_export_path = export_path

func execute() -> void:
	match _export_type:
		ExportTypes.Types.JSON_EXPORT:
			export_json()
		ExportTypes.Types.CSV_EXPORT:
			export_csv()

func export_json() -> void:
	var levels = _get_level_paths()
	if levels.size() == 0:
		print("Found no levels within the project.")
	DirAccess.make_dir_absolute(_export_path + EXPORT_LEVEL_DIR) ## TODO: Change this to create the same directory structure as the project in the export path.
	for level in levels:
		var data = _package_data(level)
		var file_path = _export_path + EXPORT_LEVEL_DIR + "/" + level.substr(level.rfind("/") + 1).get_slice(".", 0) + ".json"
		var output_file = FileAccess.open(file_path, FileAccess.WRITE)
		var output : Dictionary = {}
		output[Level.get_ID_key()] = data[Level.get_ID_key()]
		output[NODE_KEY_NAME] = []
		if output_file:
			for node in data[Level.get_nodes_key()]:
				## Build the node with only data meant for external use.
				var output_node = _construct_node(node)
				## Add the connection's to the node...
				_connect_node(output_node, data[Level.get_connection_key()])
				## Add the node to output
				output[NODE_KEY_NAME].append(output_node)

			output_file.store_string(JSON.stringify(output, "\t", false))
			output_file.close()
		else:
			print("Failed to open: ", file_path + " Error: ", error_string(FileAccess.get_open_error()))

func export_csv() -> void:
	var levels = _get_level_paths()
	if levels.size() == 0:
		print("Found no levels within the project.")
	for level in levels:
		var data = _package_data(level)


func _get_level_paths() -> PackedStringArray:
	var levels : PackedStringArray
	var project_path = GraphEditor.get_current_project_dir()
	var project := DirAccess.open(project_path)
	if project:
		var files = project.get_files() ## Check the root for levels..
		for file in files:
			if file.contains(FileIO.LEVEL_EXT):
				levels.append(project_path + "/" + file) ## Absolute path

		## Recurse the directories for levels
		var dirs = project.get_directories()
		for dir in dirs:
			_scan_directory(project_path + "/" + dir, levels)
	else:
		print("Failed to open: %s", project_path, " Error Code: ", error_string(DirAccess.get_open_error()))
	return levels


func _scan_directory(path : String, levels : PackedStringArray) -> void:
	var files = DirAccess.get_files_at(path)
	for file in files:
		if file.contains(FileIO.LEVEL_EXT):
			levels.append(path + "/" + file)
	var dirs = DirAccess.get_directories_at(path)
	for dir in dirs:
		_scan_directory(path + "/" + dir, levels)

## Packages all of the level and node data into a dictionary and returns it.
func _package_data(level) -> Dictionary:
	var data = {}
	var file = FileAccess.open(level, FileAccess.READ)
	if file:
		data = JSON.parse_string(file.get_as_text())
	else:
		print("Failed to open: %s", file, " Error Code: ", error_string(FileAccess.get_open_error()))
	file.close()
	return data

## Takes in the node's data, and only add's the required data for export, returns the built node.
func _construct_node(node) -> Dictionary:
	var out_node = {
	BaseStoryNode.get_name_key() : node[BaseStoryNode.get_name_key()],
	BaseStoryNode.get_ID_key() : node[BaseStoryNode.get_ID_key()],
	BaseStoryNode.get_prerquisites_key() : [], ## Add the prerequisites as an empty key. The connection export operation will add to it.
	}
	var node_properties = node[BaseStoryNode.get_data_key()]
	if node_properties:
		for property in node_properties:
			out_node[property] = node_properties[property]
	return out_node

## Adds the from connections of the given node as prerquisites.. The connections are saved as the quest id.
func _connect_node(output_node, connections):
	for con in connections:
		## if the current node is equal to the to_node of the connection
		if con["to_node"] == output_node[BaseStoryNode.get_ID_key()]:
			## Add it's from connection.
			output_node[BaseStoryNode.get_prerquisites_key()].append(con["from_node"])

func _link_level():
	pass
