extends PopupMenu
class_name GraphContextMenu

enum {
	ADD_TEMPLATE,
	CREATE_TEMPLATE,
	RENAME_NODE,
	DELETE_NODE,
	ADD_NODE,
	RENAME_LEVEL,
	DELETE_LEVEL
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func add_node_options():
	add_item("Add Template", ADD_TEMPLATE)
	add_item("Create Template", CREATE_TEMPLATE)
	add_item("Rename", RENAME_NODE)
	add_item("Delete", DELETE_NODE)

func add_graph_options():
	add_item("Add Node", ADD_NODE)
	add_item("Rename Level", RENAME_LEVEL)
	add_item("Delete Level", DELETE_LEVEL)

func create_template_submenu():
	##TODO: Add a list of the templates that can be added.
	pass
