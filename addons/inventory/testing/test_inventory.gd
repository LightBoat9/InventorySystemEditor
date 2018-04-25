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
	test_slots()
	test_slots_drag_return()
	test_complete()
	
func test_instance():
	new("inheritance")
	var inventory = load("res://addons/inventory/types/inventory.gd").new()
	# Assert the script is instanced
	test(inventory, "inventory instanced successfully", "inventory creation failed", "not null instance")
	
func test_custom_slot():
	new("custom_slots")
	# Assert default slot path
	test(inventory.custom_slot == "res://addons/inventory/types/inventory_slot.gd", 
		 "inventory default custom slot is correct", "inventory default custom slot is incorrect", 
		 "res://addons/inventory/types/inventory_slot.gd")
	# Assert changed custom_slot
	inventory.custom_slot = "res://addons/inventory/testing/custom_slot.gd"
	test(inventory.custom_slot == "res://addons/inventory/testing/custom_slot.gd", "changed custom_slot is correct", 
		 "changed custom_slot is incorrect", "res://addons/inventory/testing/custom_slot.gd")
	# Assert the slots are added back successfully
	test(len(inventory.arr_slots) == 4, "custom_slot successfully added slots back", 
		 "custom_slot failed to add slots back", 4)
	# Assert the slots are the correct type
	test(typeof(inventory.arr_slots[0]) == typeof(load("res://addons/inventory/testing/custom_slot.gd")),
		 "custom_slots are the correct type", "custom_slots are the incorrect type", 
		 typeof(load("res://addons/inventory/testing/custom_slot.gd")))
	# Assert the slots are created from the correct script
	test(inventory.arr_slots[0].get_script().get_path() == "res://addons/inventory/testing/custom_slot.gd",
		 "custom_slots are from the correct script", "custom_slots are from the incorrect script", 
		 "res://addons/inventory/testing/custom_slot.gd")
		
func test_slots():
	new("slots")
	# Assert the default
	test(inventory.slots == Vector2(2,2), "default slots is correct", "default slots is incorrect", 
		 Vector2(2,2))
	# Assert changing slots works
	inventory.slots = Vector2(5,5)
	test(inventory.slots == Vector2(5,5), "changed slots is correct", "changed slots is incorrect expected", 
		 Vector2(5,5))
	# Assert the size of arr_slots updates
	test(len(inventory.arr_slots) == inventory.slots.x * inventory.slots.y, "arr_slots size is correct", 
		 "arr_slots size is incorrect", inventory.slots.x * inventory.slots.y)
	# Assert the item is added back
	test(len(inventory.arr_items) > 0, "arr_items size is correct", "arr_items size is incorrect", 1)
	# Assert the item is the same instance
	test(len(inventory.arr_items) > 0 and inventory.arr_items[0] == test_item, "test_item instance is correct", 
		 "test_item instance is incorrect", test_item)
	
func test_slots_drag_return():
	new("slots_drag_return")
	# Assert default value
	test(inventory.slots_drag_return == true, "slots_drag_return default value is correct", 
		 "slots_drag_return default value is incorrect", true)
	# Assert all of the slots have the default value
	var value = true
	for slot in inventory.arr_slots:
		if slot.item_drag_return != true:
			value = false
	test(value, "slots item_drag_return value is correct", "one or more sltos item_drag_return value is incorrect", 
		 true)
	# Assert changed value
	inventory.slots_drag_return = false
	test(inventory.slots_drag_return == false, "slots_drag_return changed value is correct", 
		 "slots_drag_return changed value is correct", false)
	# Assert slots changed value
	value = true
	for slot in inventory.arr_slots:
		if slot.item_drag_return != false:
			value = false
	test(value, "slots item_drag_return changed value is correct", 
		 "one or more sltos item_drag_return changedvalue is incorrect", true)
	
func test_complete():
	print("★ testing complete ★")
	print(str(test_count) + " total tests")
	print(str(fail_count) + " failed tests")