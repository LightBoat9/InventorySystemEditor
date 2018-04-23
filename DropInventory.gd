tool
extends "res://addons/inventory/types/inventory.gd"

func _ready():
	get_parent().get_node("Inventory").connect("item_forced_out", self, "_item_forced_out")
	
func _item_forced_out(item):
	add_item(item)