extends DragNumberedItem

func _init():
	max_stack = 20
	item_name = "armor"
	categories.append("equip_body")
	texture = preload("res://kenney_assets/kenney_rpg/kenney_armor.png")
