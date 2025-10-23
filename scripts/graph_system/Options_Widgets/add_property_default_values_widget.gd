extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func is_array(value : bool):
	if value: 
		$"DefaultKey".visible = false
		$"VSeparator".visible = false