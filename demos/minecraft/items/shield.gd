extends DragNumberedItem

func _init():
	max_stack = 20
	item_name = "shield"
	categories.append("equip_shield")
	texture = preload("res://kenney_assets/kenney_rpg/kenney_shield.png")
