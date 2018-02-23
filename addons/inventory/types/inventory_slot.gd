tool
extends Sprite

var InventoryItem = load("res://addons/inventory/types/inventory_item.gd")

export var scale_item = false

var item = null

func _enter_tree():
	add_to_group("inventory_slots")
	texture = load("res://addons/inventory/assets/slot.png")
	centered = false
	set_process(true)
	
func set_item(item):
	self.item = item
	item.position = Vector2()
	item.z_index = z_index + 1
	
	if scale_item:
		item.scale = texture.get_size() / item.texture.get_size()
	
	item.slot = self
	item.get_parent().remove_child(item)
	add_child(item)