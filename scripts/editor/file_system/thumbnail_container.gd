extends ScrollContainer

@export var box_select_color : Color

var _selected_thumbnails : Array[ThumbnailBase]

var select_start_pos : Vector2 = Vector2.ZERO
var is_selecting : bool = false
@onready var box_selector : ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	box_selector = ColorRect.new()
	get_tree().current_scene.call_deferred("add_child", box_selector)
	box_selector.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	box_selector.z_as_relative = false
	box_selector.layout_direction = Control.LAYOUT_DIRECTION_APPLICATION_LOCALE
	box_selector.color = box_select_color
	box_selector.size_flags_vertical = Control.SIZE_EXPAND
	box_selector.size_flags_horizontal = Control.SIZE_EXPAND

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_LEFT:
			clear_selected_items()
			is_selecting = true
			select_start_pos = get_viewport().get_mouse_position()
			box_selector.visible = true
			box_selector.position = select_start_pos
			box_selector.size = Vector2.ZERO
	elif event is InputEventMouseButton and event.is_released():
		if is_selecting:
			is_selecting = false
			box_selector.visible = false
			check_selected_items()
	if is_selecting:
		update_selection_box(get_viewport().get_mouse_position())
		check_selected_items()

func check_selected_items():
	var selector_rect : Rect2 = box_selector.get_global_rect()
	var thumbnails = get_child(0).get_children()
	for thumbnail in thumbnails:
		var thumbnail_rect = thumbnail.get_global_rect()
		if selector_rect.intersects(thumbnail_rect):
			thumbnail.set_selected(true)
			_selected_thumbnails.append(thumbnail)

func clear_selected_items():
	for thumbnail in _selected_thumbnails:
		thumbnail.set_selected(false)
	_selected_thumbnails.clear()

func update_selection_box(pos : Vector2):
	if not get_global_rect().has_point(pos):
		box_selector.visible = false
	var min_x = min(select_start_pos.x, pos.x)
	var max_x = max(select_start_pos.x, pos.x)
	var min_y = min(select_start_pos.y, pos.y)
	var max_y = max(select_start_pos.y, pos.y)

	box_selector.position = Vector2(min_x, min_y)
	box_selector.size = Vector2(max_x - min_x, max_y - min_y)
