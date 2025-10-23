extends HBoxContainer


@onready var type_options = $TypeOption
@onready var value_editor_container = $ValueContainer

var current_editor


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	type_options.item_selected.connect(on_type_change)

func is_array(value : bool):
	if value:
		$"DefaultKey".visible = false
		$"VSeparator".visible = false

func on_type_change(type : int):
	clear_container_values()
	if current_editor:
		value_editor_container.remove_child(current_editor)
	match type:
		Types.ARRAY:
			current_editor = self.duplicate()
			current_editor.is_array(true)
			value_editor_container.add_child(current_editor)
		Types.DICTIONARY:
			current_editor = self.duplicate()
			current_editor.is_array(false)
			value_editor_container.add_child(current_editor)
		Types.FLOAT:
			current_editor = SpinBox.new()
			value_editor_container.add_child(current_editor)
		Types.INT:
			current_editor = SpinBox.new()
			value_editor_container.add_child(current_editor)
		Types.TEXT:
			current_editor = TextEdit.new()
			value_editor_container.add_child(current_editor)
		Types.BOOL:
			current_editor = OptionButton.new()
			value_editor_container.add_child(current_editor)

func clear_container_values():
	var values = value_editor_container.get_children()
	for i in range(values.size()):
		values[i].queue_free()