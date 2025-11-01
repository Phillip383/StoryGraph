extends InspectorChildBase

const ADD_PROPERTY_EDITOR = "res://scenes/UI/Property_Editor/Add_Property/add_node_property_widget.tscn"

## SIGNALS
signal property_added(active_node : Node)

@onready var editor_container = $Value_Editor_C
@onready var customize_property_widget = $Value_Editor_C/CustomizeProperty

var editor
var key
var data
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	FileManager.post_level_load.connect(on_level_changed)

func _on_node_details_item_selected(item : Variant, m_data) -> void:
	if editor:
		editor.queue_free()

	customize_property_widget.visible = true
	customize_property_widget.populate_values(item, m_data)

func _on_graph_node_deselected(_node: Node) -> void:
	save_value()
	customize_property_widget.clear_widget() ## Clear and make the customize widget invisible.
	if editor:
		editor.queue_free()

func save_value():
	if editor and data: ## Only save data changes if we were changing data.
		data[key] = editor.text

func _on_add_property_button_pressed(node : Node) -> void:
	customize_property_widget.clear_widget()
	var menu = load(ADD_PROPERTY_EDITOR).instantiate()
	menu._active_node = node
	menu.property_added.connect(on_property_added)
	if is_instance_valid(editor):
		save_value()
		editor.queue_free()
	editor = menu
	editor_container.add_child(menu)

func on_property_added(node : Node):
	property_added.emit(node)

# Clears the previously edited properties when the level is changed.
func on_level_changed(_level: Level) -> void:
	if customize_property_widget:
		customize_property_widget.clear_widget()
	if editor:
		editor.queue_free()
	if _level and not _level.node_deselected.is_connected(_on_graph_node_deselected):
		_level.node_deselected.connect(_on_graph_node_deselected)
