extends ThumbnailBase

class_name LevelThumbnail

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

func _process(_delta: float) -> void:
	super._process(_delta)

func _gui_input(event: InputEvent) -> void:
	super._gui_input(event)
	if event is InputEventMouseButton and event.double_click and event.button_index != MOUSE_BUTTON_RIGHT:
		command_invoker.set_command(OpenFileCommand.new(_resource_path))
		command_invoker.execute_command()
