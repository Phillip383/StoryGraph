extends CenterContainer

const VALUE_EDITOR_RESOURCE = "res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn"

signal on_edit_canceled()
signal on_edit_confirmed()

@onready var property_name = $VBoxContainer/PropertyName
@onready var element_container = $VBoxContainer/Values
@onready var update_button = $VBoxContainer/CancelUpdateButtons/Update
@onready var cancel_button = $VBoxContainer/CancelUpdateButtons/Cancel

# Reference to the active node to update it's property.
var active_node

func _ready():
	update_button.pressed.connect(update_property)
	cancel_button.pressed.connect(cancel_property)

func update_property():
	print("updating property")
	on_edit_confirmed.emit()

func cancel_property():
	clear_widget(false)
	on_edit_canceled.emit()

## When a property is selected we call this and parse the property data passed in creating the correct GUI elements for the data types.
func populate_values(key, _active_node : BaseStoryNode):
	clear_widget(true)
	active_node = _active_node
	var data = _active_node.get_story_data()[key]
	property_name.text = key ## Set the name of the currently selected property
	## Create the top level value widget, then create the widget's for the children.
	var value_editor = load(VALUE_EDITOR_RESOURCE).instantiate()
	element_container.add_child(value_editor)
	value_editor.init_container_type(false)
	create_widget(value_editor, data)

## Create a widget for the type of data.
func create_widget(widget, data, _key = ""):
	match typeof(data):
		TYPE_ARRAY:
			widget.set_info(_key, Types.ARRAY)
			widget.set_container_size(data.size())
			for ele in data:
				var element = widget.create_element(ele, _key)
				create_widget(element, ele) ## Recursively call this method on the elements of the container, this will get any nested containers and their values.
		TYPE_DICTIONARY:
			widget.set_info(_key, Types.DICTIONARY)
			widget.set_container_size(data.size())
			for ele in data:
				var element =  widget.create_element(data[ele], ele, true)
				create_widget(element, data[ele], ele) ## Recursively call this method on the elements of the container, this will get any nested containers and their values.
		TYPE_INT:
			widget.create_int_editor()
			widget.set_info(_key, Types.INT)
			widget.set_data_in_editor(data)
		TYPE_FLOAT:
			widget.create_float_editor()
			widget.set_info(_key, Types.FLOAT)
			widget.set_data_in_editor(data)
		TYPE_BOOL:
			widget.create_bool_editor()
			widget.set_info(_key, Types.BOOL)
			widget.set_data_in_editor(data)
		TYPE_STRING:
			widget.create_text_editor()
			widget.set_info(_key, Types.TEXT)
			widget.set_data_in_editor(data)

func clear_widget(retain_visibility = false):
	property_name.text = ""
	for child in element_container.get_children():
		child.queue_free()
	visible = retain_visibility
