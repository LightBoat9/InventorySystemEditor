tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("InventoryItem", "TextureRect", preload("types/inventory_item.gd"), preload("res://addons/inventory/assets/item.svg"))
	add_custom_type("InventorySlot", "TextureRect", preload("types/inventory_slot.gd"), preload("res://addons/inventory/assets/slot.svg"))
	add_custom_type("Inventory", "Container", preload("types/inventory.gd"), preload("res://addons/inventory/assets/inventory.svg"))
	#add_autoload_singleton("InventoryController", "res://addons/inventory/types/inventory_controller.gd") 

func _exit_tree():
	remove_custom_type("InventorySlot")
	remove_custom_type("Inventory")
	remove_custom_type("InventoryItem")
	#remove_autoload_singleton("InventoryController")