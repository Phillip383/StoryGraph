extends OptionButton

class_name NodeTypeSelection

## Emitted when item is selected, passes the selected ID.
signal on_type_selected(ID : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_node_types()
	item_selected.connect(on_selection)

func add_node_types():
	add_item("Start", NodeData.NodeType.ENTRY)
	add_item("End", NodeData.NodeType.EXIT)
	add_item("Transit", NodeData.NodeType.TRANSIT)
	add_item("Link", NodeData.NodeType.LINK)

func on_selection(_index : int):
	on_type_selected.emit(get_selected_id())