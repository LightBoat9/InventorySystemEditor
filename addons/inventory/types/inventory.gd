"""
	* Caution *
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Container and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory.gd"
		
"""
tool
extends Container

signal item_added(item)
signal item_moved(item)
signal item_removed(item)
signal item_dropped(item)
signal item_stack_changed(item, amount)
signal slot_mouse_entered(slot)
signal slot_mouse_exited(slot)
signal global_mouse_entered
signal global_mouse_exited

export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Slots
export(bool) var disabled = false setget set_disabled
export(PackedScene) var custom_slot = preload("res://addons/inventory/testing/CustomSlot.tscn") setget set_custom_slot
export(int) var slots_amount = 1 setget set_slots_amount
export(int) var slots_columns = 1 setget set_slots_columns
export(Vector2) var slots_separation = Vector2() setget set_slots_separation
export(Vector2) var slots_offset = Vector2() setget set_slots_offset
# Items
export(bool) var drop_outside_remove = false
export(bool) var drop_ignore_rect = false
export(bool) var items_locked = false setget set_items_locked

const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false

var slots = []
var items = []
var dragging
var slot_mouse_over = false
var mouse_over = false

const RECT_COLOR = Color("3FC380")
const RECT_FILLED = false
	
func _ready():
	__redo_slots()
	add_to_group("inventory_nodes")
	add_to_group("inventories")
	connect("sort_children", self, "__sort_slots")
	connect("global_mouse_entered", self, "__mouse_entered")
	connect("global_mouse_exited", self, "__mouse_exited")
	connect("item_rect_changed", self, "__item_rect_changed")
	connect("visibility_changed", self, "__visibility_changed")
	
func _input(event):
	if event is InputEventMouseMotion:
		var last_mouse_over = mouse_over
		mouse_over = Rect2(rect_global_position, get_rect().size).has_point(event.global_position)
		if not last_mouse_over and mouse_over:
			emit_signal("global_mouse_entered")
		elif last_mouse_over and not mouse_over:
			emit_signal("global_mouse_exited")
	
func _draw():
	if (debug_in_editor and Engine.editor_hint) or debug_in_game:
		draw_rect(Rect2(Vector2(), get_rect().size), RECT_COLOR, RECT_FILLED)
		
func __mouse_entered():
	mouse_over = true
	
func __mouse_exited():
	mouse_over = false
	
func __slot_mouse_entered(slot):
	slot_mouse_over = true
	emit_signal("slot_mouse_entered", slot)
	
func __slot_mouse_exited(slot):
	slot_mouse_over = false
	emit_signal("slot_mouse_exited", slot)
	
func __add_slots():
	for x in range(slots_amount):
		var inst = custom_slot.instance()
		inst.inventory = self
		inst.connect("item_added", self, "__item_added")
		inst.connect("item_removed", self, "__item_removed")
		inst.connect("item_stack_changed", self, "__item_stack_changed")
		inst.connect("global_mouse_entered", self, "__slot_mouse_entered", [inst])
		inst.connect("global_mouse_exited", self, "__slot_mouse_exited", [inst])
		slots.append(inst)
		add_child(inst)
	queue_sort()
	
func __remove_slots():
	items.clear()
	slots.clear()
	var children = get_children()
	for child in children:
		if child.is_in_group("inventory_slots"):
			remove_child(child)
			child.queue_free()
			
func __redo_slots():
	var temp_items = remove_all_items()
	__remove_slots()
	__add_slots()
	add_items_array(temp_items)
	_update_slots()
	_update_rect()
			
func __item_added(item):
	if not items.has(item):
		items.append(item)
		item.visible = visible
		item.lock_inventory = items_locked
		item.connect("drop_outside_slot", self, "__item_outside_slot", [item])
		item.connect("stack_changed", self, "__item_stack_changed", [item])
		emit_signal("item_added", item)
	else:
		emit_signal("item_moved", item)
	
func __item_removed(item):
	items.erase(item)
	item.disconnect("drop_outside_slot", self, "__item_outside_slot")
	item.disconnect("stack_changed", self, "__item_stack_changed")
	emit_signal("item_removed", item)
	
func __item_stack_changed(amount, item):
	for i in items:  # Remove deleted items
		if i == item and item.stack == 0 and item.remove_if_empty:
			items.remove(items.find(item))
	emit_signal("item_stack_changed", item, amount)
	
func __item_outside_slot(position, item):
	if item.slot and drop_outside_remove:
		if item.slot:
			item.slot.remove_item()
		emit_signal("item_dropped", item)
		
func __item_rect_changed():
	_update_rect()
	call_deferred("_align_slots")
	
func __sort_slots():
	var children = get_children()
	var pos = Vector2()
	for child in children:
		if child.is_in_group("inventory_slots"):
			child.rect_position = slots_offset + Vector2(pos.x * (slots_separation.x + child.rect_size.x), 
				pos.y * (slots_separation.y + child.rect_size.y))
			pos.x += 1
			if int(pos.x) % slots_columns == 0:
				pos.y += 1
				pos.x = 0
	_update_rect()
	
func __visibility_changed():
	for item in items:
		item.visible = visible
	
func _align_slots():
	for slot in slots:
		slot.align_item()
	
func _update_rect():
	var max_size = Vector2()
	if slots:
		max_size = slots[-1].rect_position + slots[-1].rect_size
	if rect_size.x < max_size.x:
		rect_size.x = max_size.x
	if rect_size.y < max_size.y:
		rect_size.y = max_size.y
	
func _update_slots():
	for slot in slots:
		if slot.item:
			var temp_item = slot.item # Workaround to the setget calling setter bug
			temp_item.lock_inventory = items_locked
		slot.disabled = disabled
		slot.debug_in_game = debug_in_game
		slot.debug_in_editor = debug_in_editor
	
func add_item(item, stack_first=false):
	if stack_first:
		for slot in slots:
			if slot.item and slot.item.id == item.id:
				item.set_stack(slot.item.add_stack(item.stack))
				if item.stack == 0 and item.remove_if_empty:
					return
	for slot in slots:
		if not slot.item:
			slot.set_item(item)
			return
		elif item.id == slot.item.id and item.stackable and slot.item.stackable:
			item.set_stack(slot.item.add_stack(item.stack))
			if item.stack == 0 and item.remove_if_empty:
				return
	if not item in items:
		return item
	
func add_items_array(arr):
	for item in arr:
		add_item(item)
		
func first_item():
	for slot in slots:
		if slot.item:
			return slot.item
			
func last_item():
	for i in range(len(slots)-1, -1, -1):
		if slots[i].item:
			return slots[i].item
	
func get_item(index):
	if index < 0 or index >= len(slots):
		print_stack()
		printerr("Index outside of bounds on inventory.slots")
		return
	return slots[index].item
	
func is_empty():
	return len(items) == 0
	
func has_item(id):
	for slot in slots:
		if slot.item and slot.item.id == id:
			return true
	return false
				
func remove_item(index, amount):
	if index < 0 or index >= len(slots):
		print_stack()
		printerr("Index outside of bounds on inventory.slots")
		return
	return slots[index].remove_item(int(amount))
		
func remove_all_items(id=-1):
	var arr = []
	for slot in slots:
		if slot.item and (id == -1 or slot.item.id == id):
			arr.append(slot.item)
			slot.clear_item()
	return arr
	
func find_item(id, reversed=false):
	for i in range(len(slots)):
		if reversed:
			i = len(slots) - 1 - i
		if slots[i].item and slots[i].item.id == id:
			return i
			
func set_disabled(value):
	disabled = value
	_update_slots()
			
func set_custom_slot(value):
	if value:
		custom_slot = value
		__redo_slots()
			
func set_slots_amount(value):
	slots_amount = value
	__redo_slots()
	
func set_slots_columns(value):
	if value <= 0:
		value = 1
	slots_columns = value
	queue_sort()
	
func set_slots_separation(value):
	slots_separation = value
	queue_sort()
	
func set_slots_offset(value):
	slots_offset = value
	queue_sort()
	
func set_debug_in_game(value):
	debug_in_game = value
	_update_slots()
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	_update_slots()
	update()
	
func set_items_locked(value):
	items_locked = value
	_update_slots()