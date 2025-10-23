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

@onready var property_name = $VBoxContainer/HBoxContainer/Name
@onready var type_options = $VBoxContainer/HBoxContainer/TypeOption
@onready var add_button = $VBoxContainer/Buttons/AddButton
@onready var container_options = $VBoxContainer/ContainerTypesOptions
@onready var container_values = $VBoxContainer/Values
@onready var container_size = $VBoxContainer/ContainerTypesOptions/SpinBox

const REQUIRED_NAME_LENGTH = 2

## Cached value for the currently selected type.
var current_type
var previous_value_editor

## The node we are adding a property too.
var active_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button.pressed.connect(on_add_request)
	container_size.value_changed.connect(on_container_size_change)
	type_options.item_selected.connect(on_type_select)
	property_name.text_changed.connect(on_property_named)

func on_property_named(text : String):
	if not add_button.visible and text.length() >= REQUIRED_NAME_LENGTH:
		add_button.visible = true ## I would make this more robust, but I want to allow empty default values.
	else: 
		add_button.visible = false

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

## Listens for the current selected type, this method updates visibility of the value widgets.
func on_type_select(item : int):
	if previous_value_editor:
		clear_previous_value()

	current_type = item
	match item:
		Types.ARRAY:
			container_options.visible = true
			container_values.visible = true
		Types.DICTIONARY:
			container_options.visible = true
			container_values.visible = true
		Types.BOOL:
			previous_value_editor = $VBoxContainer/BooleanValue
			$VBoxContainer/BooleanValue.visible = true
		Types.TEXT:
			previous_value_editor = $VBoxContainer/TextValue
			$VBoxContainer/TextValue.visible = true
		Types.INT:
			previous_value_editor = $VBoxContainer/IntValue
			$VBoxContainer/IntValue.visible = true
		Types.FLOAT:
			previous_value_editor = $VBoxContainer/FloatValue
			$VBoxContainer/FloatValue.visible = true

func clear_previous_value():
	match current_type:
		Types.ARRAY:
			container_options.visible = false
			container_values.visible = false
			return
		Types.DICTIONARY:
			container_options.visible = false
			container_values.visible = false
			return
	previous_value_editor.visible = false

func _on_close_button_pressed() -> void:
	queue_free()

func on_add_request():
	## TODO: Add validity checks.
	print("Adding Property to: ", active_node)
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