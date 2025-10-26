extends HBoxContainer

signal on_size_change(value)

@onready var value_box : Label = $SizeLabel

const MIN := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Decrement".pressed.connect(on_decrement)
	$"Increment".pressed.connect(on_increment)

func on_increment():
	var value = value_box.text as int + 1
	value_box.text = str(value)
	on_size_change.emit(value)

func on_decrement():
	var value = value_box.text as int
	if value == 0: ## Don't decrement or emit the signal if the value is 0
		return
	value -= 1
	value_box.text = str(value)
	on_size_change.emit(value)