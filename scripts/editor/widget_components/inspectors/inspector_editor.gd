extends InspectorChildBase

@onready var editor_container = $Value_Editor_C

var editor
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_node_details_item_selected(data: Variant) -> void:
	match typeof(data):
		TYPE_STRING:
			editor = TextEdit.new()
			editor.text = data
			editor_container.add_child(editor)

func _on_graph_node_deselected(_node: Node) -> void:
	## TODO: Save the value before closing
	editor_container.remove_child(editor)
