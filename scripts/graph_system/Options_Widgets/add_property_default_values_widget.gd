extends HBoxContainer


@onready var type_options = $TypeOption
@onready var value_editor_container = $ValueContainer/ValueList
@onready var container_size_container = $ContainerSize
@onready var container_size = $ContainerSize/SpinBox



var current_editor
var current_type

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_options.item_selected.connect(on_type_change)
	container_size.value = 1
	container_size.value_changed.connect(on_container_size_change)

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
	var text_edit = TextEdit.new()
	text_edit.custom_minimum_size = Vector2(400, 300)
	text_edit.wrap_mode = TextEdit.LINE_WRAPPING_BOUNDARY
	container_size_container.visible = false
	value_editor_container.add_child(text_edit)

func create_bool_editor():
	var bool_editor = OptionButton.new()
	bool_editor.add_item("false", 0)
	bool_editor.add_item("true", 1)
	bool_editor.selected = -1
	bool_editor.custom_minimum_size = Vector2(100, 10)
	container_size_container.visible = false
	value_editor_container.add_child(bool_editor)

func create_int_editor():
	var int_editor = SpinBox.new()
	int_editor.step = 1
	int_editor.allow_greater = true
	int_editor.allow_lesser = true
	int_editor.custom_minimum_size = Vector2(100, 20)
	container_size_container.visible = false
	value_editor_container.add_child(int_editor)

func create_float_editor():
	var float_editor = SpinBox.new()
	float_editor.step = 0.01
	float_editor.allow_greater = true
	float_editor.allow_lesser = true
	float_editor.custom_minimum_size = Vector2(100, 20)
	container_size_container.visible = false
	value_editor_container.add_child(float_editor)