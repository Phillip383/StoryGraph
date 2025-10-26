extends HBoxContainer

signal on_size_change(value)

@onready var value_box : SpinBox = $"SpinBox"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Decrement".pressed.connect(on_decrement)
	$"Increment".pressed.connect(on_increment)
	value_box.value_changed.connect(value_changed)

func on_increment():
	value_box.value += 1

func on_decrement():
	value_box.value -= 1

func value_changed(value):
	on_size_change.emit(value)