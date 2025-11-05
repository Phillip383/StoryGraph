extends Window

@export var NEW_PROJECT_WINDOW : PackedScene
@export var IMPORT_WINDOW : PackedScene
@export var PROJECT_LIST_ELEMENT : PackedScene

@onready var project_list : VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/MarginContainer/ProjectList

signal on_selection(_project : String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(on_close_request)
	add_projects()

func _on_search_text_changed(new_text: String) -> void:
	var projects = project_list.get_children() as Array[ProjectListElement]
	for project in projects:
		if not project.get_project_name().contains(new_text):
			project.visible = false
		else:
			project.visible = true
	if new_text.length() <= 0:
		for project in projects:
			project.visible = true

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
	if FileManager.is_in_active_project():
		queue_free()

func add_projects():
	# element.set_icon() #TODO: when project settings are created add this...
	var proj_list = GraphEditor.get_project_list()
	if proj_list:
		for proj in proj_list:
			for proj_name in proj:
				var element : ProjectListElement = PROJECT_LIST_ELEMENT.instantiate()
				element.on_selection.connect(project_selected)
				project_list.add_child(element)
				element.set_project_name(proj_name)
				element.set_project_path(proj[proj_name])

func project_selected(_project):
	on_selection.emit(_project)
	FileManager.open_project(_project)
	queue_free()

func on_close_request():
	if FileManager.is_in_active_project():
		queue_free()
