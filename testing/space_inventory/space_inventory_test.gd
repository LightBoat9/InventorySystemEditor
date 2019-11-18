extends Control

const Pistol = preload("res://testing/space_inventory/items/pistol.gd")
const Bullet = preload("res://testing/space_inventory/items/bullet.gd")

func _ready():
	var inst = Pistol.new()
	$SpaceInventory.add_item(inst, Vector2(0, 0))
	inst = Pistol.new()
	$SpaceInventory.add_item(inst, Vector2(2, 0))
	inst = Bullet.new()
	$SpaceInventory.add_item(inst, Vector2(4, 0))
