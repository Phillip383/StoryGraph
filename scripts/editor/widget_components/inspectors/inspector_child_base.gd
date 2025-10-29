extends MarginContainer

class_name InspectorChildBase

## EXPORTS
@export var tab_name := ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass ## Set up the signal for the child inspectors to call up the tree and change other inspectors based on their state if needed.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func get_tab_name():
	return tab_name
