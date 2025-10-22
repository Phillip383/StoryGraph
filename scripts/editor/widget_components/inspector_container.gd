extends TabContainer

class_name InspectorContainer 

"""
Base Class for the various types of inspectors and editors. The design decision is for a future layout option as to where inspectors and editors can be changed.
The class manages change and update requests for it's children.
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
This method is called when a request is received from a signal to update the currently active child of the container.
@param change : Control - the incoming change being made.

An example of this is when a property is being added or removed from a graph node inside of a graph.
Children of a tab container must implement on_change_request(change : Variant) as this method calls that method
and it's up to the child to make the change.
"""
func update_children(context : Array[Variant]):
	for child in get_children():
		child.on_change_request(context)
