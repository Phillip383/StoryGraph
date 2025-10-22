extends Resource

class_name StoryData

## Essentially the status of a quest, an enum in engine of choice will need to be implemented for this in the same order.
enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

## TODO [SCRUM-4]: Ensure when customizing node data that I implement a system to accommodate this structure
@export_category("Quest Data")
var quest_id : int 
@export var data : Dictionary[StringName, Variant]