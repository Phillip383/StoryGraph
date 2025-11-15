extends InspectorChildBase
class_name NodeDetails

## SIGNALS
## Emitted when a property in the list is selected, emits the property name, and the active node.
signal property_selected(key : Variant, node : BaseStoryNode)

## Emitted when the add property button is pressed. Emits the active node.
signal add_property(active_node : Node)

@onready var _property_list : ItemList = $VBoxContainer/PropertyList_SC/PropertyList
@onready var _add_property_button : Button = $VBoxContainer/HBoxContainer/Buttons/AddPropertyButton

var _active_node : BaseStoryNode


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_add_property_button.pressed.connect(_on_add_property_request)
	_property_list.item_selected.connect(_on_property_selected)

func _on_graph_node_selected(node : BaseStoryNode):
	_active_node = node
	_add_button_state(true)
	_display_node_properties()

func _on_graph_node_deselected():
	_add_button_state(false)
	_clear_node_properties()

func _on_add_property_request():
	_property_list.deselect_all()
	add_property.emit(_active_node)

func _on_property_selected(index : int):
	var property_name = _property_list.get_item_text(index)
	property_selected.emit(property_name, _active_node)


func _add_button_state(state : bool):
	_add_property_button.disabled = !state

func _display_node_properties():
	var node_properties = _active_node.get_story_data_key()
	var node_templates = _active_node.get_template_component().get_templates()
	for key in node_templates:
		_property_list.add_item(key)
	for key in node_properties:
		_property_list.add_item(key)

func _clear_node_properties():
		_property_list.clear()


func _on_property_edit_canceled() -> void:
	_property_list.deselect_all()

func _on_property_added(_node) -> void:
	_clear_node_properties()
	_display_node_properties()

## Clears the currently active node, and node properties from the inspector.
func _on_level_changed(_level: Level) -> void:
	_clear_node_properties()
	_active_node = null
