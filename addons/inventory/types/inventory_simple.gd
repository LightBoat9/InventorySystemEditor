tool
extends Control

var InventorySlot = load("res://addons/inventory/types/inventory_slot.gd")

var arr_slots = []
var _temp_items = []
var arr_items = []
var arr_items_dropped = []

export(int) var hslots = 2 setget set_hslots
export(int) var vslots = 2 setget set_vslots
export(int) var hoffset = 32 setget set_hoffset
export(int) var voffset = 32 setget set_voffset

func _enter_tree():
	_remove_slots()
	_add_slots()
	
func _add_slots():
	for y in range(hslots):
		for x in range(vslots):
			var inst = InventorySlot.new()
			inst.position = Vector2(x * hoffset, y * voffset)
			inst.connect("item_added", self, "_item_added")
			inst.connect("item_removed", self, "_item_removed")
			add_child(inst)
			arr_slots.append(inst)
	_add_removed_items()
			
func _remove_slots():
	while len(arr_items_dropped):
		arr_items.append(arr_items_dropped.pop_front())
	_temp_items = arr_items.duplicate()
	arr_items.clear()
	while arr_slots.size():
		arr_slots.pop_back().queue_free()
		
func _update_slot_position():
	for y in range(hslots):
		for x in range(vslots):
			arr_slots[x+(y*vslots)].position = Vector2(x * hoffset, y * voffset)
			
func _item_added(item):
	arr_items.append(item)
	
func _item_removed(item):
	arr_items.erase(item)
	
func _add_removed_items():
	for slot in arr_slots:
		if len(_temp_items):
			slot.set_item(_temp_items.pop_front())
		else:
			break
	for item in _temp_items:
		arr_items_dropped.append(item)
	_temp_items.clear()
			
func set_hslots(value):
	_remove_slots()
	hslots = value
	_add_slots()
	
func set_vslots(value):
	_remove_slots()
	vslots = value
	_add_slots()
	
func set_hoffset(value):
	hoffset = value
	_update_slot_position()
	
func set_voffset(value):
	voffset = value
	_update_slot_position()
	