extends DragNumberedItem

func _init():
	max_stack = 20
	item_name = "helmet"
	categories.append("equip_head")
	texture = preload("res://kenney_assets/kenney_rpg/kenney_helmet.png")
