extends OptionButton

class_name TypeOption

"""
When using this option button, do not use conditional expressions with the selected index, as that does not match the item ID's of the built in engine type's. You will not get the intended behavior. Use the get_selected_item_id method from the selected index, and use that value for your conditional expressions, or you can use the signal type_selected that is emitted when a selection takes place, and it passes the ID of the selected Item.
"""

## Emitted when a selection occurs and passes the ID of the selected item.
signal type_selected(ID : int)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_type_selections()
	selected = -1 ## Start with no item selected...
	item_selected.connect(on_selection)

func get_selected_item_ID() -> int:
	return get_item_id(selected)

func select_item_by_ID(ID : int) -> void:
	select(get_item_index(ID))

## Add's the type options to the button. The item ID's are the Global engine types.
func add_type_selections():
	add_item("Bool", TYPE_BOOL)
	add_item("Int", TYPE_INT)
	add_item("Float", TYPE_FLOAT)
	add_item("Text", TYPE_STRING)
	add_item("Dictionary", TYPE_DICTIONARY)
	add_item("Array", TYPE_ARRAY)

func on_selection(index : int):
	type_selected.emit(get_item_id(index))