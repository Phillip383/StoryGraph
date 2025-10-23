extends InspectorChildBase

@onready var editor_container = $Value_Editor_C

var editor
var key
var data
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_node_details_item_selected(item : Variant, m_data) -> void:
	if editor:
		editor.queue_free()

	key = item
	data = m_data
	match typeof(data[item]):
		TYPE_STRING:
			editor = TextEdit.new()
			editor.text = data[item]
			editor_container.add_child(editor)
		TYPE_STRING_NAME:
			editor = TextEdit.new()
			editor.text = data[item]
			editor_container.add_child(editor)

func _on_graph_node_deselected(_node: Node) -> void:
	save_value()
	if editor:
		editor_container.remove_child(editor)

func save_value():
	if editor and data: ## Only save data changes if we were changing data.
		data[key] = editor.text

func _on_add_property_button_pressed(node : Node) -> void:
	var menu = load("res://scenes/UI/Popups/Add_Property/add_node_property_widget.tscn").instantiate()
	menu.active_node = node
	if editor:
		save_value()
		editor_container.remove_child(editor)
	editor = menu
	editor_container.add_child(menu)
