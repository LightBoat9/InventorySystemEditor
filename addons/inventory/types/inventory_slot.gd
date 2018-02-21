tool
extends Sprite

var InventoryItem = load("res://addons/inventory/types/inventory_item.gd")

func _enter_tree():
	texture = load("res://addons/inventory/assets/slot.png")
	centered = false
	
	var item = InventoryItem.new()
	item.texture = load("res://addons/inventory/assets/sword.png")
	
func set_item(item):
	if item:
		item.queue_free()
	add_child(item)