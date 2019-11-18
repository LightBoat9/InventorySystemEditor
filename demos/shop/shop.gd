extends Control

const Steak = preload("res://demos/shop/items/steak.gd")
const Cheese = preload("res://demos/shop/items/cheese.gd")

export var coins: int = 10 setget set_coins
export var shop_coins: int = 100 setget set_shop_coins

func _ready() -> void:
	self.coins = coins
	self.shop_coins = shop_coins
	
	var inst = Steak.new()
	inst.stack = 15
	$Shop/VBoxContainer/Shop/DragSlot.item = inst
	
	inst = Cheese.new()
	inst.stack = 15
	$Shop/VBoxContainer/Shop/DragSlot2.item = inst

func set_coins(to: int) -> void:
	coins = to
	$Inventory/VBoxContainer/CoinContainer.amount = coins
	
func set_shop_coins(to: int) -> void:
	shop_coins = to
	$Shop/VBoxContainer/HBoxContainer/CoinContainer.amount = shop_coins
