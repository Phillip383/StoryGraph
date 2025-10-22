extends MarginContainer

class_name InspectorChildBase

## SIGNALS
"""
When any change occurs this is emitted.
When the event is emitted a context array of the event is created and provided.
The context can contain anything, but the best is: [EventType, self : Node, InstigatingObject : Node, Description : String]
The object that emitted the signal as well as any target can be sent as well.
To connect the signal to all of the containers call the static GraphEditor.init_connections(Node) method in _ready, pass the node needing to be connected (self).
The method binds the signal to the change_children() method of the containers.
This was done so the application wouldn't have to search the scene tree for every child of the inspectors.
"""
signal on_changed(context : Array[Variant])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GraphEditor.init_connections(self) ## Set up the signal for the child inspectors to call up the tree and change other inspectors based on their state if needed.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
