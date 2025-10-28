extends Window

class_name WarningPopup

@onready var message_box : Label = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/MessageBox
@onready var accept_button : Button = $PanelContainer/MarginContainer/CenterContainer/VBoxContainer/OkButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position = get_parent().position + (get_parent().size / 2) - (size / 2) ## Position is the center of this popup's parent.
	accept_button.pressed.connect(queue_free) # when accept is pressed delete the popup
	close_requested.connect(queue_free) # when "x" is pressed close the popup

func set_message(message : String):
	message_box.text = message
