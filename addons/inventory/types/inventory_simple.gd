tool
extends Control

var InventorySlot = load("res://addons/inventory/types/inventory_slot.gd")

var arr_slots = []
var _temp_items = []
var arr_items = []
var arr_items_dropped = []

var mouse_over = false
var _mouse_relative = Vector2()
var drag_region
var dragging = false

export(int) var hslots = 2 setget set_hslots
export(int) var vslots = 2 setget set_vslots
export(int) var hoffset = 32 setget set_hoffset
export(int) var voffset = 32 setget set_voffset
export(bool) var draggable = true
export(Vector2) var drag_top_left = Vector2()
export(Vector2) var drag_bottom_right = Vector2(64, 64)

func _enter_tree():
	_remove_slots()
	_add_slots()
	if draggable:
		add_to_group("inventory_dragabbles")
	else:
		if is_in_group("inventory_dragabbles"):
			remove_from_group("inventory_dragabbles")
	
func _ready():
	set_process_input(true)
	set_physics_process(true)
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = (
			event.position.x >= rect_position.x + drag_top_left.x and event.position.x <= rect_position.x + drag_bottom_right.x and
			event.position.y >= rect_position.y + drag_top_left.y and event.position.y <= rect_position.y + drag_top_left.y + drag_bottom_right.y
			)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if draggable:
				if mouse_over:
					dragging = event.pressed
					_mouse_relative = rect_position - get_global_mouse_position()
				else:
					dragging = false
				if dragging:
					for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
						if inst != self:
							inst.dragging = false
			
func _physics_process(delta):
	if dragging:
		rect_position = get_global_mouse_position() + _mouse_relative
	
func _add_slots():
	for y in range(hslots):
		for x in range(vslots):
			var inst = InventorySlot.new()
			inst.rect_global_position = Vector2(x * hoffset, y * voffset)
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
		var inst = arr_slots.pop_back()
		if inst.get_parent():
			inst.get_parent().remove_child(inst)
		
func _update_slot_position():
	for y in range(hslots):
		for x in range(vslots):
			arr_slots[x+(y*vslots)].rect_position = Vector2(x * hoffset, y * voffset)
			
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
	