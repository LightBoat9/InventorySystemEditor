extends DragNumberedItem

func _init():
	max_stack = 20
	item_name = "gloves"
	categories.append("equip_hands")
	texture = preload("res://kenney_assets/kenney_rpg/kenney_gloves.png")
