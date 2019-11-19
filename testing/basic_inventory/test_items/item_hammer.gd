extends DragNumberedItem

func _init().():
	max_stack = 99
	item_name = "hammer"
	categories.append("tool")
	texture = preload("res://kenney_assets/kenney_generic/genericItem_color_023.png")
