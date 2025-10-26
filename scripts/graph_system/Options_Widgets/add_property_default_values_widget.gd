extends HBoxContainer

## Emitted whenever a value is changed.
signal value_changed(value)

@onready var type_options = $TypeOption
@onready var value_editor_container = $ValueContainer/ValueList
@onready var container_size_container = $ContainerSize
@onready var container_size = $ContainerSize/SpinBox
@onready var key_name = $DefaultKey

var current_type

## Tracks the current editor open for this value widget so accessing it's data is achievable.
var editor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_options.item_selected.connect(on_type_change)
	container_size.value = 1
	container_size.value_changed.connect(on_container_size_change)
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

# Clears the container elements from the GUI when the type changes.
func clear_container_values():
	container_size_container.visible = false
	container_size.value = 1
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

func create_bool_editor():
	editor = OptionButton.new()
	editor.add_item("false", 0)
	editor.add_item("true", 1)
	editor.selected = -1
	editor.custom_minimum_size = Vector2(100, 10)
	editor.item_selected.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)

func create_int_editor():
	editor = SpinBox.new()
	editor.step = 1
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	editor.value_changed.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)

func create_float_editor():
	editor = SpinBox.new()
	editor.step = 0.01
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	editor.value_changed.connect(on_value_changed)
	container_size_container.visible = false
	value_editor_container.add_child(editor)

func create_array_editor():
	container_size_container.visible = true
	var array = load(scene_file_path).instantiate()
	array.key_and_separator_visibility(false)
	value_editor_container.add_child(array)

func create_dict_editor():
	container_size_container.visible = true
	var dict = load(scene_file_path).instantiate()
	dict.key_and_separator_visibility(true)
	value_editor_container.add_child(dict)
