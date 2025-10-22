extends Resource

class_name StoryData

## Essentially the status of a quest, an enum in engine of choice will need to be implemented for this in the same order.
enum Status {
	NOT_STARTED,
	IN_PROGRESS,
	COMPLETED,
	FAILED
}

# ACTUAL DATA
@export_category("Quest Data")
var quest_id : int
@export var status : Status
@export var quest_title : StringName
@export var description : String
@export var prerequisites : Dictionary[StringName, Array] ## Using a dict{string, array} format for this so it's flexible 
@export var rewards : Dictionary[StringName, Variant] ## Using a dict{string, Variant} format for this so it's flexible "{name}{reward}", IE. "experience: 1400"