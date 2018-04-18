tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("InventoryItem", "TextureRect", preload("types/inventory_item.gd"), preload("res://addons/inventory/assets/item.svg"))
	add_custom_type("InventorySlot", "TextureRect", preload("types/inventory_slot.gd"), preload("res://addons/inventory/assets/slot.svg"))
	add_custom_type("InventorySimple", "TextureRect", preload("types/inventory_simple.gd"), preload("res://addons/inventory/assets/inventory.svg"))

func _exit_tree():
	remove_custom_type("InventorySlot")
	remove_custom_type("InventorySimple")
	remove_custom_type("InventoryItem")