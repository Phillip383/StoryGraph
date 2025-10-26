extends CenterContainer

## This widget is used for container types values
var CONTAINER_VALUE_SCENE : PackedScene = load("res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn")

## SIGNALS
signal property_added(active_node : Node) ## Emitted when a property is successfully added to the active node.

@onready var property_name = $VBoxContainer/HBoxContainer/Name
@onready var type_options = $VBoxContainer/HBoxContainer/TypeOption
@onready var add_button = $VBoxContainer/Buttons/AddButton
@onready var container_options = $VBoxContainer/ContainerTypesOptions
@onready var container_values = $VBoxContainer/Values
@onready var container_size = $VBoxContainer/ContainerTypesOptions/SpinBox

const REQUIRED_NAME_LENGTH = 2

## Cached value for the currently selected type.
var _current_type
var _current_value_editor

## The node we are adding a property too.
var _active_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button.pressed.connect(on_add_request)
	container_size.value_changed.connect(on_container_size_change)
	type_options.item_selected.connect(on_type_select)
	property_name.text_changed.connect(on_property_named)

func on_property_named(text : String):
	## TODO [SCRUM-5]: Validate that a property with the given name doesn't already exist.
	if text.length() >= REQUIRED_NAME_LENGTH:
		add_button.visible = true ## I would make this more robust, but I want to allow empty default values.
	else: 
		add_button.visible = false

## Updates the number of visible default values for the container type property.
func on_container_size_change(value : float):
	var current_count = container_values.get_child_count()

	if value < current_count:
		var diff = current_count - value
		for i in range(diff - 1, -1, -1):
			if container_values.get_child(i):
				container_values.remove_child(container_values.get_child(i))
	else:
		var diff = value - current_count ## Only add values for the difference of existing values and new ones.
		for i in range(diff):
			var new_value = CONTAINER_VALUE_SCENE.instantiate()
			if _current_type == Types.ARRAY: ## If it's an array value, hide the separator and key value.
				new_value.is_array(true)
			container_values.add_child(new_value)

## Listens for the current selected type, this method updates visibility of the value widgets.
func on_type_select(item : int):
	if _current_value_editor:
		remove_previous_value_editor()
	clear_container_values()
	_current_type = item
	match item:
		Types.ARRAY:
			container_options.visible = true
			container_values.visible = true
			# TODO: Remove the old array values
		Types.DICTIONARY:
			container_options.visible = true
			container_values.visible = true
			# TODO: Remove the old Dictionary values
		Types.BOOL:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/BooleanValue
			$VBoxContainer/BooleanValue.visible = true
		Types.TEXT:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/TextValue
			$VBoxContainer/TextValue.visible = true
		Types.INT:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/IntValue
			$VBoxContainer/IntValue.visible = true
		Types.FLOAT:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/FloatValue
			$VBoxContainer/FloatValue.visible = true

func remove_previous_value_editor():
	match _current_type:
		Types.ARRAY:
			container_options.visible = false
			container_values.visible = false
			return
		Types.DICTIONARY:
			container_options.visible = false
			container_values.visible = false
			return
	_current_value_editor.visible = false

func clear_container_values():
	var values = container_values.get_children()
	for i in range(values.size()):
		values[i].queue_free()
	container_size.value = 0

func _on_close_button_pressed() -> void:
	queue_free()

func on_add_request():
	match _current_type:
		Types.ARRAY:
			var _arr = []
			for child in container_values.get_children():
				_arr.append(child.get_value())
			_active_node.add_data(property_name.text, _arr)
		Types.DICTIONARY:
			var _dict = {}
			for child in container_values.get_children():
				_dict[child.get_key_name()] = child.get_value()
			_active_node.add_data(property_name.text, _dict)
		Types.BOOL:
			add_bool()
		Types.INT:
			add_int()
		Types.FLOAT:
			add_float()
		Types.TEXT:
			add_text()

	property_added.emit(_active_node)
	reset()


func add_text():
	_active_node.add_data(property_name.text, _current_value_editor.text)

func add_bool():
	var selected = true if _current_value_editor.selected == 1 else false
	_active_node.add_data(property_name.text, selected)

func add_int():
	_active_node.add_data(property_name.text, _current_value_editor.value as int)

func add_float():
	_active_node.add_data(property_name.text, _current_value_editor.value)

func reset():
	clear_container_values()
	remove_previous_value_editor()
	property_name.text = ""
	type_options.selected = -1
