"""
	* Caution *
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Sprite and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory.gd"
		
"""
tool
extends GridContainer

signal item_added
signal item_moved
signal item_removed
signal item_dropped
signal item_stack_changed
signal slot_mouse_entered
signal slot_mouse_exited

export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Slots
export(PackedScene) var custom_slot = preload("res://addons/inventory/testing/CustomSlot.tscn") setget set_custom_slot
export(Vector2) var slots_amount = 1 setget set_slots_amount
# Drag
export(bool) var draggable = true
export(bool) var hold_to_drag = false
# Items
export(bool) var drop_outside_slot = false

const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false

var slots = []
var items = []
var items_dropped = []

var drag_region
var dragging

var slot_mouse_over = false
var mouse_over = false

const RECT_COLOR = Color("3FC380")
const RECT_FILLED = false

func _enter_tree():
	__redo_slots()
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventories")
	
func _draw():
	if (debug_in_editor and Engine.editor_hint) or debug_in_game:
		draw_rect(Rect2(Vector2(), get_rect().size), RECT_COLOR, RECT_FILLED)
	
func __slot_mouse_entered():
	slot_mouse_over = true
	
func __slot_mouse_exited():
	slot_mouse_over = false
	
func __not_custom_slot():
	if not custom_slot:
		printerr("Custom slot is null on %s (%s)" % [str(self), self.name])
		return true
	else:
		return false
	
func __add_slots():
	if __not_custom_slot():
		return
	if len(slots):
		__remove_slots()
	for x in range(slots_amount):
		var inst = custom_slot.instance()
		inst.inventory = self
		inst.connect("item_added", self, "__item_added")
		inst.connect("item_removed", self, "__item_removed")
		inst.connect("item_stack_changed", self, "__item_stack_changed")
		inst.connect("mouse_entered", self, "__slot_mouse_entered")
		inst.connect("mouse_exited", self, "__slot_mouse_exited")
		slots.append(inst)
		add_child(inst)
	
func __remove_slots():
	items.clear()
	while slots.size():
		slots.pop_back().free()
			
func __redo_slots():
	var temp_items = remove_all_items()
	__remove_slots()
	__add_slots()
	add_items(temp_items)
	_update_slots()
			
func __item_added(item):
	if not items.has(item):
		items.append(item)
		emit_signal("item_added", item)
	else:
		emit_signal("item_moved", item)
	
func __item_removed(item):
	items.erase(item)
	emit_signal("item_removed", item)
	
func __item_stack_changed(item):
	# Remove deleted items
	for i in items:
		if i == item and item.stack == 0:
			items.remove(items.find(item))
	emit_signal("item_stack_changed", item)
	
func __item_outside_slot(item):
	if drop_outside_slot and item.slot:
		if item in items:
			items.erase(item)
		item.remove_from_tree()
		items_dropped.append(item)
		emit_signal("item_dropped", item)
	
func _update_slots():
	if __not_custom_slot() or not len(slots):
		return
	for slot in slots:
		slot.debug_in_game = debug_in_game
		slot.debug_in_editor = debug_in_editor
	
func add_item(item):
	for slot in slots:
		if not slot.item:
			slot.set_item(item)
		elif slot.item.id == item.id:
			var overflow = slot.item.add_stack(item.stack)
			item.set_stack(overflow)
			if overflow != 0 or item.remove_if_empty:
				slot.set_item(item)
	if not item in items:
		item.remove_from_tree()
		items_dropped.append(item)
		emit_signal("item_dropped", item)
	
func add_items(arr):
	for item in arr:
		add_item(item)
		
func remove_all_items():
	var arr = []
	for slot in slots:
		if slot.item:
			arr.append(slot.remove_item())
	return arr
			
func set_custom_slot(value):
	custom_slot = value
	__redo_slots()
			
func set_slots_amount(value):
	slots_amount = value
	__redo_slots()
	
func set_debug_in_game(value):
	debug_in_game = value
	_update_slots()
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	_update_slots()
	update()
	
func make_top():
	"""Orders all inventory_nodes by their z_index and makes self the top z_index"""
	var all_nodes = get_tree().get_nodes_in_group("inventories") + items_no_slot()
	var nodes = []
	for inst in all_nodes:
		if inst != self:
			var index = len(nodes)-1
			while not inst in nodes:
				if not len(nodes):
					nodes.append(inst)
				elif inst.z_index < nodes[index].z_index:
					nodes.insert(index, inst)
				elif inst.z_index >= nodes[index].z_index:
					nodes.insert(index+1, inst)
				index += 1
	nodes.append(self)
	for i in len(nodes):
		nodes[i].z_index = i