extends Node
	
var test_count = 0
var fail_count = 0
	
# Test inventory
var inventory = load("res://addons/inventory/types/inventory.gd").new()
var test_item = load("res://addons/inventory/types/inventory_item.gd").new()
	
func new(text):
	print("●⚫⚫⚫⬤ testing " + text + " ●")
	
func test(condition, success_text, fail_text, expected_vaulue):
	test_count += 1
	if condition:
		print("[✔] " + success_text)
	else:
		fail_count += 1
		printerr("[❌✘] " + fail_text + " expected " + str(expected_vaulue))
	
func _ready():
	add_child(inventory)
	inventory.add_item(test_item)
	test_instance()
	test_custom_slot()
	test_complete()
	
func test_instance():
	new("inheritance")
	var inventory = load("res://addons/inventory/types/inventory.gd").new()
	# Assert the script is instanced
	test(inventory, "inventory instanced successfully", "inventory creation failed", "not null instance")
	
func test_custom_slot():
	new("custom_slots")
	# Assert default slot path
	test(inventory.custom_slot == load("res://addons/inventory/types/inventory_slot.gd"), 
		 "inventory default custom slot is correct", "inventory default custom slot is incorrect", 
		 "res://addons/inventory/types/inventory_slot.gd")
	# Assert changed custom_slot
	inventory.custom_slot = load("res://addons/inventory/testing/custom_slot.gd")
	test(inventory.custom_slot == load("res://addons/inventory/testing/custom_slot.gd"), "changed custom_slot is correct", 
		 "changed custom_slot is incorrect", "res://addons/inventory/testing/custom_slot.gd")
	# Assert the slots are added back successfully
	test(len(inventory.slots) == 4, "custom_slot successfully added slots back", 
		 "custom_slot failed to add slots back", 4)
	# Assert the slots are the correct type
	test(typeof(inventory.slots[0]) == typeof(load("res://addons/inventory/testing/custom_slot.gd")),
		 "custom_slots are the correct type", "custom_slots are the incorrect type", 
		 typeof(load("res://addons/inventory/testing/custom_slot.gd")))
	# Assert the slots are created from the correct script
	test(inventory.slots[0].get_script().get_path() == "res://addons/inventory/testing/custom_slot.gd",
		 "custom_slots are from the correct script", "custom_slots are from the incorrect script", 
		 "res://addons/inventory/testing/custom_slot.gd")
	
func test_complete():
	print("★ testing complete ★")
	print(str(test_count) + " total tests")
	print(str(fail_count) + " failed tests")