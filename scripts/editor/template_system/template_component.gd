extends RefCounted
class_name TemplateComponent

##@class
##Component class to give node's template functionality.

@export var _templates : Dictionary = {}

signal template_added(template)

func get_templates():
	return _templates

func set_templates(templates):
	_templates = templates

## Adds a template to this components list.
##@Param - template_name: The name of the template to add.
##@Param - template: The template to add.
##@Returns - True if the template was successfully added. False otherwise.
func add_template(template_name : String, template : Dictionary) -> bool:
	if _check_template_key_integrity(template) == OK:
		_templates[template_name] = template
		template_added.emit(template)
		return true
	else:
		##TODO: Tell the user why the operation failed.
		return false

func find_template(template_name : String) -> Dictionary:
	return _templates.get(template_name)

func remove_template(template_name : String) -> bool:
	return _templates.erase(template_name)

## Updates an edited template, retains the values for existing properties, unless that property was removed from the template. That data is lost.
func update_template(template_name : String, template : Dictionary):
	var values = _templates.get(template_name)
	if values:
		for key in values:
			template[key] = values[key]
	_templates[template_name] = template

## The function checks the existing template's keys against the newly added template, if any key's confilt, the function returns false
## This is required, as upon export, template properties are exported on the node, template's are only a internal tool to manage data as it matures.
func _check_template_key_integrity(new_template : Dictionary) -> Error:
	for template in _templates:
		for key in _templates[template].keys():
			if new_template.has(key):
				return ERR_DUPLICATE_SYMBOL
	return OK
