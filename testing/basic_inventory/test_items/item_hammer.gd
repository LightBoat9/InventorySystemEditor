extends Item

const texture: Texture = preload("res://kenney_assets/kenney_generic/genericItem_color_023.png")

func _init():
	item_name = "hammer"
	categories.append("tool")

func get_item_texture() -> Texture:
	return texture
