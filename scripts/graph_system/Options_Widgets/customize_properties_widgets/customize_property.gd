extends CenterContainer

const VALUE_EDITOR_RESOURCE = "res://scenes/UI/Popups/Add_Property/add_property_default_values_widget.tscn"

@onready var property_name = $VBoxContainer/PropertyName
@onready var element_container = $VBoxContainer/Values

## When a property is selected we call this and parse the property data passed in creating the correct GUI elements for the data types.
func populate_values(key, data : Variant):
	clear_widget(true)
	property_name.text = key ## Set the name of the currently selected property
	var contents = data[key]
	if contents is Array or contents is Dictionary:
		for content in contents:
			create_widget(content)
	else:
		create_widget(data[key])

## Create a widget for the type of data.
func create_widget(content):
	match typeof(content):
		TYPE_ARRAY:
			pass
		TYPE_DICTIONARY:
			pass
		TYPE_INT:
			print(content)
			pass
		TYPE_FLOAT:
			pass
		TYPE_BOOL:
			pass
		TYPE_STRING:
			pass

func clear_widget(retain_visibility = false):
	property_name.text = ""
	for child in element_container.get_children():
		child.queue_free()
	visible = retain_visibility
