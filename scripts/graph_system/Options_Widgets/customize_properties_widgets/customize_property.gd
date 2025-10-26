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
	value_editor.key_and_separator_visibility(false)
	element_container.add_child(value_editor)
	if contents is Array:
		for content in contents:
			create_widget(value_editor, content)
	elif contents is Dictionary:
		for content in contents:
			create_widget(value_editor, [content, contents[content]]) ## Passes the key name and content in an array.
	else:
		create_widget(value_editor, data[key])

## Create a widget for the type of data.
func create_widget(widget, content):
	print(content)
	var editor
	match typeof(content):
		TYPE_ARRAY:
			editor = widget.create_array_editor()
		TYPE_DICTIONARY:
			editor = widget.create_dict_editor()
		TYPE_INT:
			editor = widget.create_int_editor()
			widget.set_info("", Types.INT)
			editor.value = content as int
		TYPE_FLOAT:
			editor = widget.create_float_editor()
			widget.set_info("", Types.FLOAT)
			editor.value = content as float
		TYPE_BOOL:
			editor = widget.create_bool_editor()
			widget.set_info("", Types.BOOL)
			editor.selected = content
		TYPE_STRING:
			editor = widget.create_text_editor()
			widget.set_info("", Types.TEXT)
			editor.text = content

func clear_widget(retain_visibility = false):
	property_name.text = ""
	for child in element_container.get_children():
		child.queue_free()
	visible = retain_visibility
