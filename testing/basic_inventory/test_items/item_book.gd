extends Item

const texture: Texture = preload("res://kenney_assets/kenney_generic/genericItem_color_035.png")

func _init():
	item_name = "book"

func get_item_texture() -> Texture:
	return texture
