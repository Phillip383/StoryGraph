extends HBoxContainer

## Emitted whenever a value is changed.
signal value_changed(value)

@onready var type_options = $TypeOption
@onready var value_editor_container = $ValueContainer/ValueList
@onready var container_size_container = $ContainerSizeWidget
@onready var container_size : Label = $ContainerSizeWidget/SizeLabel
@onready var key_name = $DefaultKey

var current_type

## Tracks the current editor open for this value widget so accessing it's data is achievable.
var editor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_options.item_selected.connect(on_type_change)
	container_size.text = str(0)
	container_size_container.on_size_change.connect(on_container_size_change)
	value_changed.connect(on_value_changed)

func on_value_changed(_value):
	pass

func get_value():
	match current_type:
		Types.ARRAY:
			# Loop all of the children getting their values.
			var _arr = []
			for child in value_editor_container.get_children():
				_arr.append(child.get_value())
			return _arr
		Types.DICTIONARY:
			# Loop all of the children getting their keys and values
			var _dict = {}
			for child in value_editor_container.get_children():
				_dict[child.get_key_name()] = child.get_value()
			return _dict
		Types.TEXT:
			return editor.text
		Types.INT:
			return editor.value
		Types.FLOAT:
			return editor.value
		Types.BOOL:
			return editor.selected

func get_key_name():
	return key_name.text

func set_key_name(_name):
	key_name.text = _name

func set_type(_type):
	current_type = _type
	type_options.selected = _type

func set_info(_name, _type):
	set_type(_type)
	set_key_name(_name)

func set_data_in_editor(data):
	match typeof(data):
		TYPE_INT:
			editor.value = data
		TYPE_FLOAT:
			editor.value = data
		TYPE_BOOL:
			editor.selected = data
		TYPE_STRING:
			editor.text = data

func set_container_size(_size : int):
	container_size.text = str(_size)

## Adds a editor widget to the foldable value container on this widget
func add_value_editor(widget):
	value_editor_container.add_child(widget)

## Simple method to set the state between a dictionary or array container type.
func key_and_separator_visibility(value : bool):
	$"DefaultKey".visible = value
	$"VSeparator".visible = value

# Updates the type of editor depending on the data type selected.
func on_type_change(type : int):
	current_type = type
	clear_container_values()
	match type:
		Types.ARRAY:
			create_array_editor()
		Types.DICTIONARY:
			create_dict_editor()
		Types.FLOAT:
			create_float_editor()
		Types.INT:
			create_int_editor()
		Types.TEXT:
			create_text_editor()
		Types.BOOL:
			create_bool_editor()

# Setups a container type, such as the size setting of the container.
func init_container_type(b_show_key_name : bool):
	key_and_separator_visibility(b_show_key_name)
	container_size_container.visible = true

# Clears the container elements from the GUI when the type changes.
func clear_container_values():
	container_size_container.visible = false
	container_size.text = str(1)
	var values = value_editor_container.get_children()
	for i in range(values.size()):
		values[i].queue_free()

# Updates the number of elements available to be set in the GUI.
func on_container_size_change(value : float):

	var current_count = value_editor_container.get_child_count()

	if value < current_count:
		var diff = current_count - value
		for i in range(diff - 1, -1, -1):
			value_editor_container.get_child(i).queue_free()
	else:
		var diff = value - current_count ## Only add values for the difference of existing values and new ones.
		for i in range(diff):
			var new_value = load(scene_file_path).instantiate()
			if current_type == Types.ARRAY: ## If it's an array value, hide the separator and key value.
				new_value.key_and_separator_visibility(false)
			value_editor_container.add_child(new_value)

	value_changed.emit(value) ## Inform the top level of the data change.

func create_text_editor():
	editor = TextEdit.new()
	editor.custom_minimum_size = Vector2(400, 300)
	editor.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	container_size_container.visible = false
	value_editor_container.add_child(editor)
	return editor

func create_bool_editor():
	editor = OptionButton.new()
	editor.add_item("false", 0)
	editor.add_item("true", 1)
	editor.selected = -1
	editor.custom_minimum_size = Vector2(100, 10)
	editor.item_selected.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)
	return editor

func create_int_editor():
	editor = SpinBox.new()
	editor.step = 1
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	editor.value_changed.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)
	return editor

func create_float_editor():
	editor = SpinBox.new()
	editor.step = 0.01
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	editor.value_changed.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)
	return editor

func create_array_editor():
	container_size_container.visible = true
	var array = load(scene_file_path).instantiate()
	array.key_and_separator_visibility(false)
	value_editor_container.add_child(array)
	return array

func create_dict_editor():
	container_size_container.visible = true
	var dict = load(scene_file_path).instantiate()
	dict.key_and_separator_visibility(true)
	value_editor_container.add_child(dict)
	return dict

## Method creates and returns a widget for editing the given data type.
func create_editor_from_data(data):
	match typeof(data):
		TYPE_ARRAY:
			return create_array_editor()
		TYPE_DICTIONARY:
			return create_dict_editor()
		TYPE_INT:
			return create_int_editor()
		TYPE_FLOAT:
			return create_float_editor()
		TYPE_BOOL:
			return create_bool_editor()
		TYPE_STRING:
			return create_text_editor()

"""
Creates a container element.
"""
func create_element(data = null, _key = "", is_dict_element = false):
	var _type = get_type(data)
	container_size_container.visible = true
	var element = load(scene_file_path).instantiate()
	element.key_and_separator_visibility(is_dict_element)
	add_value_editor(element)
	return element

"""
	TODO:
	Checks the incoming data against built in types and returns my Enum type. Will refactor this out, and switch to just using the built in type. Once I get to a point of functionality working as intended. I do not want to refactor this and break something in this state.
"""
func get_type(data):
	match typeof(data):
		TYPE_ARRAY:
			return Types.ARRAY
		TYPE_DICTIONARY:
			return Types.DICTIONARY
		TYPE_STRING:
			return Types.TEXT
		TYPE_INT:
			return Types.INT
		TYPE_FLOAT:
			return Types.FLOAT
		TYPE_BOOL:
			return Types.BOOL
