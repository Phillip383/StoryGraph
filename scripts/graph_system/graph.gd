extends GraphEdit

@export var context_menu_offset := Vector2.ZERO ## The offset to spawn the contextual from the mouse cursor

@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_request.connect(_on_popup_request)
	context_menu.connect("_on_add_node", _on_add_node)
	connection_request.connect(_on_connection)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_popup_request(location : Vector2):
	context_menu.position = location + context_menu_offset
	context_menu.show()

func _on_add_node(node : GraphNode):
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	add_child(node)

func _on_connection(from_node: StringName, from_port: int, to_node: StringName, to_port: int):
	connect_node(from_node, from_port, to_node, to_port)