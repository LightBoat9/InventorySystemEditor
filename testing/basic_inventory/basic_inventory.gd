extends Control

const item_hammer = preload("res://testing/basic_inventory/test_items/item_hammer.gd")
const item_book = preload("res://testing/basic_inventory/test_items/item_book.gd")

func _ready() -> void:
	var ham = item_hammer.new()
	ham.stack = 4
	$InventoryContainer/DragSlot.item = ham
	
	var book = item_book.new()
	book.stack = 4
	$InventoryContainer/DragSlot2.item = book
	
	for slot in $InventoryContainer2.get_children():
		var book2 = item_book.new()
		book2.stack = book2.max_stack
		slot.item = book2
