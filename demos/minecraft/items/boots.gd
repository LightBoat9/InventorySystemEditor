extends Item

const texture: Texture = preload("res://kenney_assets/kenney_rpg/colored712.png")

func _init():
	item_name = "boots"
	categories.append("equip_feet")

func get_item_texture() -> Texture:
	return texture
