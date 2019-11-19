extends SpaceNumberedItem

func _init().():
	item_name = "bullet"
	max_stack = 15
	span = Vector2(1, 1)
	texture = preload("res://kenney_assets/kenney_weapons/ammo_pistol.png")
