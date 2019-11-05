extends Control

const item_hammer = preload("res://testing/basic_inventory/test_items/item_hammer.gd")
const item_book = preload("res://testing/basic_inventory/test_items/item_book.gd")

func _ready() -> void:
	for child in $InventoryContainer.get_children():
		var ham = item_hammer.new()
		ham.stack = 5
		child.item = ham
		
	for child in $InventoryContainer3.get_children():
		var ham = item_hammer.new()
		ham.stack = 5
		child.item = ham
	
	var book = item_book.new()
	book.stack = 5
	$InventoryContainer2/DragSlot.item = book
	
	var book2 = item_book.new()
	book2.stack = 5
	$InventoryContainer2/DragSlot2.item = book2