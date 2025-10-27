extends OptionButton

class_name NodeTypeSelection

const DEFAULT_SELECTION_ID = 10

## Emitted when item is selected, passes the selected ID.
signal on_type_selected(ID : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_node_types()
	item_selected.connect(on_selection)
	selected = get_item_index(DEFAULT_SELECTION_ID)

func get_default_id():
	return DEFAULT_SELECTION_ID

func add_node_types():
	add_item("Type", DEFAULT_SELECTION_ID)
	add_item("Start", NodeData.NodeType.ENTRY)
	add_item("End", NodeData.NodeType.EXIT)
	add_item("Transit", NodeData.NodeType.TRANSIT)
	add_item("Link", NodeData.NodeType.LINK)
	set_item_disabled(get_item_index(DEFAULT_SELECTION_ID), true)

func on_selection(_index : int):
	on_type_selected.emit(get_selected_id())