tool
extends Control

var InventorySlot = load("res://addons/inventory/types/inventory_slot.gd")

var arr_slots = []

export(int) var hslots = 2 setget set_hslots
export(int) var vslots = 2 setget set_vslots
export(int) var hoffset = 32 setget set_hoffset
export(int) var voffset = 32 setget set_voffset

func _enter_tree():
	_add_slots()
	
func _add_slots():
	for y in range(hslots):
		for x in range(vslots):
			var inst = InventorySlot.new()
			inst.position = Vector2(x * hoffset, y * voffset)
			add_child(inst)
			arr_slots.append(inst)
			
func _remove_slots():
	while arr_slots.size():
		arr_slots.pop_back().queue_free()
			
func set_hslots(value):
	_remove_slots()
	hslots = value
	_add_slots()
	
func set_vslots(value):
	_remove_slots()
	vslots = value
	_add_slots()
	
func set_hoffset(value):
	_remove_slots()
	hoffset = value
	_add_slots()
	
func set_voffset(value):
	_remove_slots()
	voffset = value
	_add_slots()
	