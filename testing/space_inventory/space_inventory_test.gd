extends Control

const Pistol = preload("res://testing/space_inventory/items/pistol.gd")
const Bullet = preload("res://testing/space_inventory/items/bullet.gd")
const Sniper = preload("res://testing/space_inventory/items/sniper.gd")

func _ready():
	var inst = Pistol.new()
	inst.stack = 5
	$SpaceInventory.add_item(inst, Vector2(0, 0))
	
	inst = Pistol.new()
	inst.stack = 5
	$SpaceInventory.add_item(inst, Vector2(2, 0))
	
	inst = Bullet.new()
	inst.stack = inst.max_stack
	$SpaceInventory.add_item(inst, Vector2(4, 0))
	
	inst = Bullet.new()
	inst.stack = inst.max_stack
	$SpaceInventory.add_item(inst, Vector2(5, 0))
	
	inst = Sniper.new()
	$SpaceInventory.add_item(inst, Vector2(0, 2))
