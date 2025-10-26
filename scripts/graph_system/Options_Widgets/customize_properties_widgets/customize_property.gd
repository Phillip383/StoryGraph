extends CenterContainer

const VALUE_EDITOR_RESOURCE = "res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn"

@onready var property_name = $VBoxContainer/PropertyName
@onready var element_container = $VBoxContainer/Values

## When a property is selected we call this and parse the property data passed in creating the correct GUI elements for the data types.
func populate_values(key, data : Variant):
	clear_widget(true)
	property_name.text = key ## Set the name of the currently selected property
	var contents = data[key]
	## Create the top level value widget, then create the widget's for the children.
	var value_editor = load(VALUE_EDITOR_RESOURCE).instantiate()
	value_editor.key_and_separator_visibility(false) ## This doesn't necessarily do what it says, and thats bad, refactor it.
	element_container.add_child(value_editor)
	if contents is Array or contents is Dictionary:
		for content in contents:
			create_widget(value_editor, content)
	else:
		create_widget(value_editor, data[key])

## Create a widget for the type of data.
func create_widget(widget, content):
	print(content)
	match typeof(content):
		TYPE_ARRAY:
			widget.create_array_editor()
		TYPE_DICTIONARY:
			widget.create_dict_editor()
		TYPE_INT:
			widget.create_int_editor()
		TYPE_FLOAT:
			widget.create_float_editor()
		TYPE_BOOL:
			widget.create_bool_editor()
		TYPE_STRING:
			widget.create_text_editor()

func clear_widget(retain_visibility = false):
	property_name.text = ""
	for child in element_container.get_children():
		child.queue_free()
	visible = retain_visibility
