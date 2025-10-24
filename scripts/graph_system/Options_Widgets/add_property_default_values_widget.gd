extends HBoxContainer


@onready var type_options = $TypeOption
@onready var value_editor_container = $ValueContainer/ValueList
@onready var container_size_container = $ContainerSize
@onready var container_size = $ContainerSize/SpinBox
@onready var key_name = $DefaultKey
var current_editor
var current_type

## Tracks the current editor open for this value widget so accessing it's data is achievable.
var editor

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_options.item_selected.connect(on_type_change)
	container_size.value = 1
	container_size.value_changed.connect(on_container_size_change)

## Returns the cached data from this node.
func get_input_data():
	match current_type:
		Types.ARRAY:
			var arr = []
			for child in value_editor_container.get_children():
				if child.has_method("get_input_data"):
					arr.append(child.get_input_data())
			return arr
		Types.DICTIONARY:
			var dict = {}
			for child in value_editor_container.get_children():
				if child.has_method("get_input_data"):
					dict[child.key_name.text] = child.get_input_data()
			return dict
		Types.INT:
			return editor.value
		Types.FLOAT:
			return editor.value
		Types.BOOL:
			return editor.selected
		Types.TEXT:
			return editor.text

func is_array(value : bool):
	if value:
		$"DefaultKey".visible = false
		$"VSeparator".visible = false

func on_type_change(type : int):
	current_type = type
	clear_container_values()
	match type:
		Types.ARRAY:
			container_size_container.visible = true
			current_editor = load(scene_file_path).instantiate()
			current_editor.is_array(true)
			value_editor_container.add_child(current_editor)
		Types.DICTIONARY:
			container_size_container.visible = true
			current_editor = load(scene_file_path).instantiate()
			current_editor.is_array(false)
			value_editor_container.add_child(current_editor)
		Types.FLOAT:
			create_float_editor()
		Types.INT:
			create_int_editor()
		Types.TEXT:
			create_text_editor()
		Types.BOOL:
			create_bool_editor()

func clear_container_values():
	container_size_container.visible = false
	container_size.value = 1
	var values = value_editor_container.get_children()
	for i in range(values.size()):
		values[i].queue_free()

func on_container_size_change(value : float):
		
	var current_count = value_editor_container.get_child_count()

	if value < current_count:
		var diff = current_count - value
		for i in range(diff - 1, -1, -1):
			value_editor_container.remove_child(value_editor_container.get_child(i))
	else:
		var diff = value - current_count ## Only add values for the difference of existing values and new ones.
		for i in range(diff):
			var new_value = load(scene_file_path).instantiate()
			if current_type == Types.ARRAY: ## If it's an array value, hide the separator and key value.
				new_value.is_array(true)
			value_editor_container.add_child(new_value)

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
	container_size_container.visible = false
	value_editor_container.add_child(editor)

func create_int_editor():
	editor = SpinBox.new()
	editor.step = 1
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	container_size_container.visible = false
	value_editor_container.add_child(editor)

func create_float_editor():
	editor = SpinBox.new()
	editor.step = 0.01
	editor.allow_greater = true
	editor.allow_lesser = true
	editor.custom_minimum_size = Vector2(100, 20)
	container_size_container.visible = false
	value_editor_container.add_child(editor)