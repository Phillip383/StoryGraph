extends CenterContainer

enum Types {
	BOOL,
	TEXT,
	INT,
	FLOAT,
	ARRAY,
	DICTIONARY
}

var CONTAINER_VALUE_SCENE : PackedScene = load("res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn")

@onready var type_options = $VBoxContainer/HBoxContainer/TypeOption
@onready var add_button = $VBoxContainer/Buttons/AddButton
@onready var container_options = $VBoxContainer/ContainerTypesOptions
@onready var value_box = $VBoxContainer/DefaultValue
@onready var container_values = $VBoxContainer/Values
@onready var container_size = $VBoxContainer/ContainerTypesOptions/SpinBox

## Cached value for the currently selected type.
var current_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button.pressed.connect(on_add_request)
	container_size.value_changed.connect(on_container_size_change)
	type_options.item_selected.connect(on_type_select)

## CONTAINER RELATED CONTROL METHODS

## Updates the number of visible default values for the container type property.
func on_container_size_change(value : float):
	var current_count = container_values.get_child_count()

	if value < current_count:
		var diff = current_count - value
		for i in range(diff):
			container_values.remove_child(container_values.get_child(i))
	else:
		var diff = value - current_count ## Only add values for the difference of existing values and new ones.
		for i in range(diff):
			var new_value = CONTAINER_VALUE_SCENE.instantiate()
			if current_type == Types.ARRAY: ## If it's an array value, hide the separator and key value.
				new_value.is_array(true)
			container_values.add_child(new_value)

## Listens for the current selected type, this method will update visibility of the widgets.
func on_type_select(item : int):
	## TODO: Clear previous types

	current_type = item
	match item:
		Types.ARRAY:
			container_options.visible = true
			container_values.visible = true
		Types.DICTIONARY:
			container_options.visible = true
			container_values.visible = true
		Types.BOOL:
			$VBoxContainer/BooleanValue.visible = true
		Types.TEXT:
			$VBoxContainer/TextValue.visible = true
		Types.INT:
			$VBoxContainer/IntValue.visible = true
		Types.FLOAT:
			$VBoxContainer/FloatValue.visible = true

## Checks the entered value if it is valid for the selected data type.
func check_value_input_type(_text: String):
	pass

func _on_close_button_pressed() -> void:
	queue_free()

func on_add_request():
	## TODO: Add validity checks.
	print("Adding Property")
	pass

func add_array():
	pass

func add_dict():
	pass

func add_text():
	pass

func add_bool():
	pass

func add_int():
	pass

func add_float():
	pass