extends InspectorChildBase


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

"""
This method is called by the parent node InspectorContainer when the container receives a request to change.
"""
func on_change_request(context : Variant):
	print(self, "Context of event: ", context)