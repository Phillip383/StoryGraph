extends InspectorChildBase

@onready var editor = $Value_Editor_C

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_node_details_item_selected(data: Variant) -> void:
	var child
	match typeof(data):
		TYPE_STRING:
			child = TextEdit.new()
			editor.add_child(child)