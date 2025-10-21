extends GraphEdit

@export var context_menu_offset := Vector2.ZERO ## The offset to spawn the contextual from the mouse cursor

@onready var context_menu = $"GraphNodeMenu"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup_request.connect(_on_popup_request)
	context_menu.connect("_on_add_node", _on_add_node)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_popup_request(location : Vector2):
	context_menu.position = location + context_menu_offset
	context_menu.show()

func _on_add_node(node : GraphNode):
	node.position_offset = (get_local_mouse_position() + scroll_offset) / zoom + - node.size / 2
	print(node.position_offset)
	add_child(node)
