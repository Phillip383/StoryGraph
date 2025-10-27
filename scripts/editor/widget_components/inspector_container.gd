extends TabContainer

class_name InspectorContainer

"""
Base Class for the various types of inspectors and editors. The design decision is for a future layout option as to where inspectors and editors can be changed.
The class manages change and update requests for it's children.
"""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_tabs_name()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
This method is called in _ready, it sets the tab names to something other than the children's top-level node name.
"""
func set_tabs_name():
	var i = 0
	for child in get_children():
		set_tab_title(i, child.get_tab_name())
		i += 1
