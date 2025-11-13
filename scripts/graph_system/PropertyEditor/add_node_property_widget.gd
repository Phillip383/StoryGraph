extends CenterContainer

class_name PropertyEditor


## This widget is used for container types values
var CONTAINER_VALUE_SCENE : PackedScene = load("res://scenes/Property_Editor/Add_Property/add_property_default_values_widget.tscn")

## SIGNALS
signal property_added(active_node : Node) ## Emitted when a property is successfully added to the active node.

@onready var property_name = $VBoxContainer/HBoxContainer/Name
@onready var type_options : TypeOption = $VBoxContainer/HBoxContainer/TypeOption
@onready var add_button = $VBoxContainer/Buttons/AddButton
@onready var container_options = $VBoxContainer/ContainerSizeWidget
@onready var container_values = $VBoxContainer/Values
@onready var message_box = $VBoxContainer/MessageBox

const REQUIRED_NAME_LENGTH = 2

var _current_value_editor

## The node we are adding a property too.
var _active_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_button.pressed.connect(on_add_request)
	container_options.on_size_change.connect(on_container_size_change)
	type_options.item_selected.connect(on_type_select)
	property_name.text_changed.connect(on_property_named)

func set_active_node(node : BaseStoryNode):
	_active_node = node

func add_button_state():
	var prop_name = property_name.text
	if prop_name.length() >= REQUIRED_NAME_LENGTH:
		if _active_node.does_property_exist(prop_name):
			message_box.text = "Property already exists"
			message_box.visible = true
			add_button.disabled = true
		elif type_options.selected == -1:
			add_button.disabled = true
			message_box.visible = true
			message_box.text = "Property need's type"
		else:
			add_button.disabled = false
			message_box.visible = false

func on_property_named(_text : String):
	add_button_state()

## Updates the number of visible default values for the container type property.
func on_container_size_change(value : float):
	var current_count = container_values.get_child_count()

	if value < current_count:
		var diff = current_count - value
		for i in range(diff - 1, -1, -1):
			if container_values.get_child(i):
				container_values.get_child(current_count - 1).queue_free()
	else:
		var diff = value - current_count ## Only add values for the difference of existing values and new ones.
		for i in range(diff):
			var new_value = CONTAINER_VALUE_SCENE.instantiate()
			if type_options.get_selected_id() == TYPE_ARRAY: ## If it's an array value, hide the separator and key value.
				new_value.key_and_separator_visibility(false)
			container_values.add_child(new_value)

## Listens for the current selected type, this method updates visibility of the value widgets.
func on_type_select(_item : int):
	if _current_value_editor:
		remove_previous_value_editor()
	clear_container_values()
	add_button_state()
	match type_options.get_selected_id():
		TYPE_ARRAY:
			container_options.visible = true
			container_values.visible = true
			if _current_value_editor:
				_current_value_editor.visible = false
		TYPE_DICTIONARY:
			container_options.visible = true
			container_values.visible = true
			if _current_value_editor:
				_current_value_editor.visible = false
		TYPE_BOOL:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/BooleanValue
			if _current_value_editor:
				_current_value_editor.visible = true
		TYPE_STRING:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/TextValue
			if _current_value_editor:
				_current_value_editor.visible = true
		TYPE_INT:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/IntValue
			if _current_value_editor:
				_current_value_editor.visible = true
		TYPE_FLOAT:
			container_options.visible = false
			_current_value_editor = $VBoxContainer/FloatValue
			if _current_value_editor:
				_current_value_editor.visible = true

func remove_previous_value_editor():
	match type_options.get_selected_id():
		TYPE_ARRAY:
			container_options.visible = false
			container_values.visible = false
			return
		TYPE_DICTIONARY:
			container_options.visible = false
			container_values.visible = false
			return
	_current_value_editor.visible = false

func clear_container_values():
	var values = container_values.get_children()
	for i in range(values.size()):
		values[i].queue_free()
	container_options.set_element_size(0)

func _on_close_button_pressed() -> void:
	queue_free()

func on_add_request():
	match type_options.get_selected_id():
		TYPE_ARRAY:
			var _arr = []
			for child in container_values.get_children():
				_arr.append(child.get_value())
			_active_node.add_data(property_name.text, _arr)
		TYPE_DICTIONARY:
			var _dict = {}
			for child in container_values.get_children():
				_dict[child.get_key_name()] = child.get_value()
			_active_node.add_data(property_name.text, _dict)
		TYPE_BOOL:
			add_bool()
		TYPE_INT:
			add_int()
		TYPE_FLOAT:
			add_float()
		TYPE_STRING:
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
