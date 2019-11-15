extends Control

const Book = preload("res://demos/shop/items/book.gd")

func _ready() -> void:
	var inst = Book.new()
	inst.stack = 15
	$Inventory/DragSlot.item = inst
