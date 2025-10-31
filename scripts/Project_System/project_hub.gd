extends Window

const NEW_PROJECT_WINDOW = preload("res://scenes/UI/Project_System/create_project_menu.tscn")
const IMPORT_WINDOW = preload("res://scenes/UI/Project_System/Open_Project_dialog.tscn")
const PROJECT_LIST_ELEMENT = preload("res://scenes/UI/Project_System/project_list_element.tscn")

@onready var project_list : VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/ProjectList

signal on_selection(_project : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(queue_free)
	add_projects()


func _on_search_text_submitted(new_text: String) -> void:
	pass # Replace with function body.


func _on_search_text_changed(new_text: String) -> void:
	pass # Replace with function body.


func _on_new_pressed() -> void:
	var window = NEW_PROJECT_WINDOW.instantiate()
	add_child(window)
	await window.on_successful_creation
	queue_free()

func _on_import_pressed() -> void:
	var window = IMPORT_WINDOW.instantiate()
	add_child(window)
	var project = await window.on_successful_selection
	FileManager.add_project_to_list(project)
	var element : ProjectListElement = PROJECT_LIST_ELEMENT.instantiate()
	element.on_selection.connect(project_selected)
	project_list.add_child(element)
	element.set_project_name(project.keys()[0])
	element.set_project_path(project.values()[0])

func _on_close_pressed() -> void:
	queue_free()

func add_projects():
	# element.set_icon() #TODO: when project settings are created add this...
	var proj_list = GraphEditor.get_project_list()
	for proj in proj_list:
		for proj_name in proj:
			var element : ProjectListElement = PROJECT_LIST_ELEMENT.instantiate()
			element.on_selection.connect(project_selected)
			project_list.add_child(element)
			element.set_project_name(proj_name)
			element.set_project_path(proj[proj_name])

func project_selected(_project):
	on_selection.emit(_project)
