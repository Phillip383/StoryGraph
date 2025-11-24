@abstract
extends RefCounted
class_name Strategy

@abstract
func _init(parent_container : Container, node : BaseStoryNode) -> void

@abstract
func execute() -> void

@abstract
func destroy() -> void
