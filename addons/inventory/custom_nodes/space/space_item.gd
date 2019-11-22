extends "res://addons/inventory/custom_nodes/base/item.gd"
class_name SpaceItem

var span: Vector2 = Vector2(1, 1)

func _draw():
	draw_rect(Rect2(Vector2(), rect_size), Color.red, false)

func _init():
	expand = true
	mouse_filter = MOUSE_FILTER_IGNORE
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
