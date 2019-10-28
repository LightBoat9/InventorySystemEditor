extends Item

const texture: Texture = preload("res://kenney_assets/kenney_rpg/colored705.png")

func _init():
	item_name = "helmet"
	categories.append("equip_head")

func get_item_texture() -> Texture:
	return texture
