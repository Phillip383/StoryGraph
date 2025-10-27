extends HBoxContainer

## Emitted whenever a value is changed.
signal value_changed(value)

@onready var type_options : TypeOption = $TypeOption
@onready var value_editor_container = $ValueContainer/ValueList
@onready var container_size_container = $ContainerSizeWidget
@onready var container_size : Label = $ContainerSizeWidget/SizeLabel
@onready var key_name = $DefaultKey

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
	match type_options.get_selected_id():
		TYPE_ARRAY:
			# Loop all of the children getting their values.
			var _arr = []
			for child in value_editor_container.get_children():
				_arr.append(child.get_value())
			return _arr
		TYPE_DICTIONARY:
			# Loop all of the children getting their keys and values
			var _dict = {}
			for child in value_editor_container.get_children():
				_dict[child.get_key_name()] = child.get_value()
			return _dict
		TYPE_STRING:
			return editor.text
		TYPE_INT:
			return editor.value as int
		TYPE_FLOAT:
			return editor.value
		TYPE_BOOL:
			return true if editor.get_selected_id() == 1 else false

func get_key_name():
	return key_name.text

func set_key_name(_name):
	key_name.text = _name

## When setting type ensure that you pass the ID of the currently selected item.
## Passing the index doesn't ensure the correct type to be selected.
func set_type(_type_ID):
	type_options.select_item_by_ID(_type_ID)

## When setting type ensure that you pass the ID of the currently selected item.
## Passing the index doesn't don't ensure the correct type to be selected.
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
func on_type_change(_type : int):
	clear_container_values()
	match type_options.get_selected_id():
		TYPE_ARRAY:
			create_array_editor()
		TYPE_DICTIONARY:
			create_dict_editor()
		TYPE_FLOAT:
			create_float_editor()
		TYPE_INT:
			create_int_editor()
		TYPE_STRING:
			create_text_editor()
		TYPE_BOOL:
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
			if type_options.get_selected_id() == TYPE_ARRAY: ## If it's an array value, hide the separator and key value.
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
func create_element(_data = null, _key = "", is_dict_element = false):
	container_size_container.visible = true
	var element = load(scene_file_path).instantiate()
	element.key_and_separator_visibility(is_dict_element)
	add_value_editor(element)
	return element
