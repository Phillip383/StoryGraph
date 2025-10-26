extends CenterContainer

const VALUE_EDITOR_RESOURCE = "res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn"

@onready var property_name = $VBoxContainer/PropertyName
@onready var element_container = $VBoxContainer/Values

## When a property is selected we call this and parse the property data passed in creating the correct GUI elements for the data types.
func populate_values(key, data : Variant):
	clear_widget(true)
	property_name.text = key ## Set the name of the currently selected property
	## Create the top level value widget, then create the widget's for the children.
	var value_editor = load(VALUE_EDITOR_RESOURCE).instantiate()
	element_container.add_child(value_editor)
	value_editor.init_container_type(false)
	create_widget(value_editor, data[key])

## Create a widget for the type of data.
func create_widget(widget, data, _key = ""):
	match typeof(data):
		TYPE_ARRAY:
			widget.set_info("", Types.ARRAY)
			for ele in data:
				var element = widget.create_element(ele, _key)
				create_widget(element, ele)
		TYPE_DICTIONARY:
			widget.set_info("", Types.DICTIONARY)
			for ele in data:
				var element =  widget.create_element(data[ele], ele)
				create_widget(element, data[ele], ele)
		TYPE_INT:
			widget.create_int_editor()
			widget.set_info("", Types.INT)
			widget.set_data_in_editor(data)
		TYPE_FLOAT:
			widget.create_float_editor()
			widget.set_info("", Types.FLOAT)
			widget.set_data_in_editor(data)
		TYPE_BOOL:
			widget.create_bool_editor()
			widget.set_info("", Types.BOOL)
			widget.set_data_in_editor(data)
		TYPE_STRING:
			widget.create_text_editor()
			widget.set_info("", Types.TEXT)
			widget.set_data_in_editor(data)

func clear_widget(retain_visibility = false):
	property_name.text = ""
	for child in element_container.get_children():
		child.queue_free()
	visible = retain_visibility
