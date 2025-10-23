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
			current_editor = SpinBox.new()
			container_size_container.visible = false
			value_editor_container.add_child(current_editor)
		Types.INT:
			current_editor = SpinBox.new()
			container_size_container.visible = false
			value_editor_container.add_child(current_editor)
		Types.TEXT:
			current_editor = TextEdit.new()
			container_size_container.visible = false
			value_editor_container.add_child(current_editor)
		Types.BOOL:
			current_editor = OptionButton.new()
			container_size_container.visible = false
			value_editor_container.add_child(current_editor)

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
