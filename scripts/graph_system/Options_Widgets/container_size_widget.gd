extends HBoxContainer

signal on_size_change(value)

@onready var value_box : Label = $SizeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Decrement".pressed.connect(on_decrement)
	$"Increment".pressed.connect(on_increment)

func on_increment():
	var value = value_box.text as int
	value_box.text = value + 1
	on_size_change.emit(value)

func on_decrement():
	var value = value_box.text as int
	value_box.text = value - 1
	on_size_change.emit(value)