extends Strategy
class_name EditLinkStrat

var _parent : Container
var _node : BaseStoryNode

func _init(parent_container : Container, node : BaseStoryNode) -> void:
	_parent = parent_container
	_node = node

func execute() -> void:
	pass

func destroy() -> void:
	pass
