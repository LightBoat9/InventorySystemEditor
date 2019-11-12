extends Control

const armor = preload("res://demos/minecraft/items/armor.gd")
const boots = preload("res://demos/minecraft/items/boots.gd")
const gloves = preload("res://demos/minecraft/items/gloves.gd")
const helmet = preload("res://demos/minecraft/items/helmet.gd")
const shield = preload("res://demos/minecraft/items/shield.gd")
const wood = preload("res://demos/minecraft/items/wood.gd")
const table = preload("res://demos/minecraft/items/table.gd")

onready var crafting_out = $Inventory/VBoxContainer/TopArea/CraftingArea/HBoxContainer/VBoxContainer/HBoxContainer/DragSlot

func _ready() -> void:
	$Inventory/VBoxContainer/Toolbar/DragSlot.item = armor.new()
	$Inventory/VBoxContainer/Toolbar/DragSlot2.item = boots.new()
	$Inventory/VBoxContainer/Toolbar/DragSlot3.item = gloves.new()
	$Inventory/VBoxContainer/Toolbar/DragSlot4.item = helmet.new()
	$Inventory/VBoxContainer/Toolbar/DragSlot5.item = shield.new()
	
	crafting_out.connect("item_removed", self, "crafting_output_removed")
	
	var inst = wood.new()
	inst.stack = 20
	$Inventory/VBoxContainer/Toolbar/DragSlot6.item = inst

func add_log(txt: String) -> void:
	$Log/VBoxContainer/Label.text += "\n%s" % txt
	
func crafting_output_removed():
	for i in get_tree().get_nodes_in_group("crafting"):
		if i.item:
			i.item.queue_free()
			i.item = null

func craft_area_changed() -> void:
	var wood_count = 0
	for i in get_tree().get_nodes_in_group("crafting"):
		if i.item and i.item.item_name == "wood":
			wood_count += 1
			
	# Hacky crafting recipe
	if wood_count == 4:
		if not crafting_out.item:
			crafting_out.item = table.new()
	else:
		if crafting_out.item:
			crafting_out.item.queue_free()
			
		crafting_out.item = null
