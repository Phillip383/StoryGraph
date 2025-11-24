extends Window

signal on_selection(selection : PromptSelection)

@onready var progress_label = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/UnsavedProgressLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(queue_free)

func _on_cancel_pressed() -> void:
	on_selection.emit(PromptSelection.CANCEL)
	queue_free()

func _on_save_pressed() -> void:
	on_selection.emit(PromptSelection.SAVE)
	queue_free()

func _on_discard_pressed() -> void:
	on_selection.emit(PromptSelection.DISCARD)
	queue_free()

func set_unsaved_progress_text(new_text : String):
	progress_label.text = new_text