extends Command
class_name ExportCommand

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
	print(levels)
	#var data = _package_data()
	## For every top level dictionary, IE, level, stringify the data and write it to a json file using the current key name as the file name. The file should be saved to the export path given. I would also like to format the JSON file with correct whitespace for readability.

func export_csv() -> void:
	var data = _package_data()



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
func _package_data() -> Dictionary:
	var levels = _get_level_paths()
	if levels.size() == 0:
		print("Found no levels within the project.")
	var data = {}
	for level in levels:
		var file = FileAccess.open(level, FileAccess.READ)
		if file:
			print(level, " opened")
		else:
			print("Failed to open: %s", file, " Error Code: ", error_string(FileAccess.get_open_error()))
		file.close()
		##TODO: Should I await and process the frame here, so the system has time to close the file before the next iteration?
	return data

func _connect_node():
	pass

func _link_level():
	pass
