extends ScrollContainer

@export var box_select_color : Color

signal selection_complete(selected_items)

var _selected_thumbnails : Array[ThumbnailBase]

var select_start_pos : Vector2 = Vector2.ZERO
var is_selecting : bool = false
var _active_thumbnail : ThumbnailBase

@onready var box_selector : ColorRect
@onready var _command_invoker : CommandInvoker = CommandInvoker.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	box_selector = ColorRect.new()
	get_tree().current_scene.call_deferred("add_child", box_selector)
	box_selector.z_index = RenderingServer.CANVAS_ITEM_Z_MAX
	box_selector.color = box_select_color


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
			selection_complete.emit(_selected_thumbnails)
	if is_selecting:
		update_selection_box(get_viewport().get_mouse_position())
		check_selected_items()


func _unhandled_input(event: InputEvent) -> void:
	if not is_selecting and event.is_action_pressed("delete") and _selected_thumbnails.size() > 0:
		_delete_selection()


func _delete_selection():
	for thumbnail in _selected_thumbnails:
		if thumbnail:
			var delete_command = DeleteFileCommand.new(thumbnail.get_resource_path())
			_command_invoker.set_command(delete_command).execute_command()
			thumbnail.queue_free()

func _get_drag_data(_at_position: Vector2) -> Variant:
	if not is_selecting and _selected_thumbnails.size() > 0:
		## TODO: Set the drag preview for the group selection.
		return _selected_thumbnails
	elif not is_selecting and _active_thumbnail:
		var drag_preview = _active_thumbnail.duplicate()
		drag_preview.deselect()
		set_drag_preview(drag_preview)
		return _active_thumbnail
	return null

func check_selected_items():
	var selector_rect : Rect2 = box_selector.get_global_rect()
	var thumbnails = get_child(0).get_children()
	for thumbnail in thumbnails:
		var thumbnail_rect = thumbnail.get_global_rect()
		if selector_rect.intersects(thumbnail_rect):
			thumbnail.set_selected(true)
			if not _selected_thumbnails.has(thumbnail):
				_selected_thumbnails.append(thumbnail)

func clear_selected_items():
	for thumbnail in _selected_thumbnails:
		if thumbnail:
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

func set_active_thumbnail(thumbnail : ThumbnailBase):
	_active_thumbnail = thumbnail

func clear_active_thumbnail():
	_active_thumbnail = null

func _on_thumbnail_entered_tree(node: Node) -> void:
	var thumbnail = node as ThumbnailBase
	if thumbnail:
		thumbnail.set_drag_forwarding(self._get_drag_data, thumbnail._can_drop_data, thumbnail._drop_data)
		thumbnail.thumbnail_hover_end.connect(clear_active_thumbnail)
		thumbnail.thumbnail_clicked.connect(set_active_thumbnail)
