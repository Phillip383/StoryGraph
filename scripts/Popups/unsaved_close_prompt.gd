extends Window

signal on_selection(selection : bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(queue_free)

func _on_cancel_pressed() -> void:
	on_selection.emit(false)
	queue_free()

func _on_save_pressed() -> void:
	on_selection.emit(true)
	queue_free()
