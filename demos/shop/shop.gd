extends Control

const Steak = preload("res://demos/shop/items/steak.gd")
const Cheese = preload("res://demos/shop/items/cheese.gd")

func _ready() -> void:
	var inst = Steak.new()
	inst.stack = 15
	$Inventory/VBoxContainer/Inventory/DragSlot.item = inst
	
	inst = Cheese.new()
	inst.stack = 15
	$Inventory/VBoxContainer/Inventory/DragSlot2.item = inst
