extends PopupMenu
class_name GraphContextMenu

## Emits the path to the template.
signal template_selected(path : String)

enum {
	ADD_TEMPLATE,
	CREATE_TEMPLATE,
	RENAME_NODE,
	DELETE_NODE,
	ADD_NODE,
	RENAME_LEVEL,
	DELETE_LEVEL
}

##Maps the template path to an id.
var template_map : Dictionary[int, String]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func add_node_options():
	add_template_submenu()
	add_item("Create Template", CREATE_TEMPLATE)
	add_item("Rename", RENAME_NODE)
	add_item("Delete", DELETE_NODE)

func add_graph_options():
	add_item("Add Node", ADD_NODE)
	add_item("Rename Level", RENAME_LEVEL)
	add_item("Delete Level", DELETE_LEVEL)

func add_template_submenu():
	##TODO: Add a list of the templates that can be added.
	var submenu : PopupMenu = PopupMenu.new()
	add_child(submenu)
	add_submenu_node_item("Add Template", submenu, ADD_TEMPLATE)
	submenu.id_pressed.connect(func(id) : template_selected.emit(template_map[id]))

	var templates: Array = GraphEditor.get_project_data()[GraphEditor.TEMPLATE_KEY]
	var id_counter : int = 0
	for _path: String in templates:
		var _name: String = _path.get_file().get_slice(".", 0)
		submenu.add_item(_name, id_counter)
		template_map[id_counter] = _path
		id_counter += 1
