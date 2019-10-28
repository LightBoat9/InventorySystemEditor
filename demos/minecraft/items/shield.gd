extends Item

const texture: Texture = preload("res://kenney_assets/kenney_rpg/colored808.png")

func _init():
	item_name = "shield"
	categories.append("equip_shield")

func get_item_texture() -> Texture:
	return texture
