tool
extends EditorPlugin

func _enter_tree():
	add_custom_type("InventoryItem", "TextureRect", preload("types/inventory_item.gd"), preload("res://icon.png"))
	add_custom_type("InventorySlot", "TextureRect", preload("types/inventory_slot.gd"), preload("res://icon.png"))
	add_custom_type("InventorySimple", "TextureRect", preload("types/inventory_simple.gd"), preload("res://icon.png"))

func _exit_tree():
	remove_custom_type("InventorySlot")
	remove_custom_type("InventorySimple")
	remove_custom_type("InventoryItem")