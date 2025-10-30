extends Control

class_name GraphManager

enum GraphState {
	IDLE, ## A neutral state
	LOADING,
	SAVING,
	EDITING, ## The unsaved state
	ERROR
}

var current_state = GraphState.IDLE

var events = {}
var actions_to_remove = ["save_all", "save", "new_node"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _change_state(new_state):
	if new_state == current_state:
		return
	_exit_state(current_state)

	current_state = new_state

	await _enter_state(current_state)

func _enter_state(_new_state):
	if _new_state == GraphState.LOADING:
		disable_input()
	elif _new_state == GraphState.SAVING:
		disable_input()
	elif _new_state == GraphState.EDITING:
		get_parent().name = get_parent().name + "*"
		GraphEditor.unsaved_levels.append(get_parent())

func _exit_state(_old_state):
	if _old_state == GraphState.LOADING or _old_state == GraphState.SAVING:
		enable_input()
	elif _old_state == GraphState.EDITING:
		GraphEditor.unsaved_levels.erase(get_parent())

func disable_input():
	get_parent().mouse_filter = Control.MOUSE_FILTER_IGNORE
	for action in actions_to_remove:
		events[action] = InputMap.action_get_events(action) ## Cache the events to the associated action.
		InputMap.action_erase_events(action) ## Erase the events

func enable_input():
	get_parent().mouse_filter = Control.MOUSE_FILTER_PASS
	for event in events:
		for bind in events[event]:
			InputMap.action_add_event(event, bind) ## Replace the events
