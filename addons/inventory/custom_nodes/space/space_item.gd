extends "res://addons/inventory/custom_nodes/base/item.gd"
class_name SpaceItem

enum Orientation {
	RIGHT,
	DOWN,
	LEFT,
	UP,
}

var span: Vector2 = Vector2(1, 1)

var orientation: int = Orientation.RIGHT

func _draw():
	draw_rect(Rect2(Vector2(), rect_size), Color.red, false)

func _enter_tree():
	expand = true
	mouse_filter = MOUSE_FILTER_IGNORE
	stretch_mode = STRETCH_KEEP_ASPECT_CENTERED
