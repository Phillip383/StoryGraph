extends Command
class_name NewNodeCommand

@export_file var NEW_NODE_WINDOW = "res://scenes/Graph/Nodes/new_node.tscn"

signal add_node_requested(node_name, node_type)

func execute() -> void:
	var menu : NewNodeWindow = load(NEW_NODE_WINDOW).instantiate()
	Engine.get_main_loop().current_scene.add_child(menu)
	menu.add_node_requested.connect(func(node_name, node_type) : add_node_requested.emit(node_name, node_type))
