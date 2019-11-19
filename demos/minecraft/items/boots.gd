extends DragNumberedItem

func _init():
	max_stack = 20
	item_name = "boots"
	categories.append("equip_feet")
	texture = preload("res://kenney_assets/kenney_rpg/kenney_boots.png")
