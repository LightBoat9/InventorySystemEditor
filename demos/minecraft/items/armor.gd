extends Item

const texture: Texture = preload("res://kenney_assets/kenney_rpg/colored741.png")

func _init():
	item_name = "armor"
	categories.append("equip_body")

func get_item_texture() -> Texture:
	return texture
