extends Window

"""
The types of graph nodes that can be added to the graph
"""
@export var node_types : Dictionary[NodeData.NodeType, PackedScene]

const REQUIRED_NAME_LENGTH = 2
const NAME_LENGTH_MESSAGE = "The required length for node names is %d" % REQUIRED_NAME_LENGTH
const EXISTS_MESSAGE = "Node already exists, choose another name."
const NO_TYPE_MESSAGE = "A node need's a type, please select a type."

var _selected_type : int
var _name : StringName

@onready var type_option : NodeTypeSelection = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/NodeType
@onready var message_box : Label = $MarginContainer/CenterContainer/VBoxContainer/MessageBox
@onready var confirm_button : Button = $MarginContainer/CenterContainer/VBoxContainer/Buttons/Confirm
@onready var text_box : LineEdit = $MarginContainer/CenterContainer/VBoxContainer/HBoxContainer/LineEdit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	close_requested.connect(_on_cancel_pressed)
	text_box.text_submitted.connect(on_submitted)
	_selected_type = type_option.get_selected_id()

func _on_type_selected(ID : int) -> void:
	_selected_type = ID
	confirm_button_state()

func _on_cancel_pressed() -> void:
	queue_free()

## creates a node of selected type and names the node; add's it to the parent graph of the window. Destroys itself once done.
func _on_confirm_pressed() -> void:
	var new_node : BaseStoryNode = node_types[_selected_type].instantiate()
	new_node.set_node_title(_name)
	get_parent().add_node(new_node)
	queue_free()

## TODO: Check the graph for any node's with existing name, disable confirm button.
func _on_name_changed(new_text: String) -> void:
	_name = new_text
	confirm_button_state()

func confirm_button_state():
	if _name.length() >= REQUIRED_NAME_LENGTH:
		if _selected_type == type_option.get_default_id(): ## If user has made no selection.
			message_box.visible = true
			message_box.text = NO_TYPE_MESSAGE
			confirm_button.disabled = true
		elif check_for_existing_node():
			message_box.visible = true
			message_box.text = EXISTS_MESSAGE
			confirm_button.disabled = true
		else:
			message_box.visible = false
			confirm_button.disabled = false
	else:
		message_box.visible = true
		message_box.text = NAME_LENGTH_MESSAGE
		confirm_button.disabled = true

func check_for_existing_node() -> bool:
	var nodes = get_parent().get_children()
	for node in nodes:
		if node is BaseStoryNode:
			if node.title == _name:
				return true

	return false

func on_submitted(_text):
	_on_confirm_pressed()