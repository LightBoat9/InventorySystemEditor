extends Item

const texture: Texture = preload("res://kenney_assets/kenney_rpg/colored714.png")

func _init():
	item_name = "gloves"
	categories.append("equip_hands")

func get_item_texture() -> Texture:
	return texture
