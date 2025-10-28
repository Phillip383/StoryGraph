extends PanelContainer

const CREATE_PROJECT_ID = 1
const OPEN_PROJECT_ID = 2
const PROJECT_CREATION_WINDOW = preload("res://scenes/UI/Project_System/create_project_menu.tscn")
const OPEN_PROJECT_WINDOW = preload("res://scenes/UI/Project_System/open_project_dialog.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func _on_file_id_pressed(id: int) -> void:
	if id == CREATE_PROJECT_ID:
		var proj_screen = PROJECT_CREATION_WINDOW.instantiate()
		get_tree().current_scene.add_child(proj_screen)
	elif id == OPEN_PROJECT_ID:
		var open_project_dialog = OPEN_PROJECT_WINDOW.instantiate()
		get_tree().current_scene.add_child(open_project_dialog)
