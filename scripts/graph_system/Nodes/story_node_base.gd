extends GraphNode

class_name BaseStoryNode

"""
The base graph node for the story graphing system.

the _properties dictionary access methods are heavily restrictive, this is intentional. Using the appropriate methods for the task at hand will help keep
the data clean, and with debugging.
"""

## TODO: Change to a Resource Class
@export_category("Node Data")
@export var _properties : Dictionary[StringName, Variant] ## The properties of this node. A dictionary of type variant so various forms of data can be stored with a key name.

## SIGNALS
signal on_property_change(property) ## Emitted when a property is added, removed, or it's value is updated.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
returns a deep copy of _properties, any changes made to the dictionary returned by this method will not be saved.
This is intended for readonly iteration.
"""
func get_properties_dict() -> Dictionary[StringName, Variant]:
	return _properties.duplicate_deep()

"""
returns a deep copy of the properties keys, no changes made to array returned from this method will be retained.
"""
func get_properties_keys() -> Array[StringName]:
	return _properties.keys().duplicate_deep()

"""
returns a deep copy of the properties values, no changes made to array returned from this method will be retained.
"""
func get_properties_values() -> Array[Variant]:
	return _properties.values().duplicate_deep()

"""
Checks if a property doesn't already exist, adds it if it doesn't.
Emits on_property_change
"""
func add_property(property_name : StringName, type : Variant) -> Error:
	if not _properties.find_key(property_name):
		return Error.ERR_ALREADY_IN_USE
	_properties[property_name] = type
	on_property_change.emit(_properties[property_name])
	return Error.OK

"""
Removes a property with given name
returns - Error.OK on erase, or Error.ERR_DOES_NOT_EXIST if it fails.
Emits on_property_change
"""
func remove_property(property_name : StringName) -> Error:
	if _properties.erase(property_name):
		on_property_change.emit(_properties[property_name])
		return Error.OK
	else:
		return Error.ERR_DOES_NOT_EXIST

"""
Sets the value of an existing property, property must exist and the value must be the same type
return Error.OK or Error.ERR_DOES_NOT_EXIST or Error.ERR_INVALID_DATA depending on the fail/success condition.
"""
func set_existing_property_value(property_name: StringName, value : Variant) -> Error:
	if not _properties.get(property_name): # The property does not exist.
		return Error.ERR_DOES_NOT_EXIST
	if not _properties.get(property_name).Type == value.Type: # Only Allow the same type
		return Error.ERR_INVALID_DATA
	
	_properties[property_name] = value
	on_property_change.emit(_properties[property_name])
	return Error.OK

"""
Erases the properties of this node.
returns Error.FAILED if the dictionary is already empty or Error.OK if successful
Emits on_property_change with null value
"""
func clear_properties() -> Error:
	if _properties.is_empty():
		return Error.FAILED
	_properties.clear()
	on_property_change.emit(null)
	return Error.OK