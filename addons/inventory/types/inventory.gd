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
extends "res://addons/inventory/types/inventory_base.gd"

signal item_added
signal item_moved
signal item_removed
signal item_dropped
signal item_stack_changed
signal mouse_entered
signal mouse_exited
signal slot_mouse_entered
signal slot_mouse_exited

export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Slots
export(PackedScene) var custom_slot = preload("res://addons/inventory/testing/CustomSlot.tscn") setget set_custom_slot
export(Vector2) var slots_amount = Vector2(2, 2) setget set_slots_amount
export(Vector2) var slots_spacing = Vector2(32, 32) setget set_slots_spacing
export(Vector2) var slots_offset = Vector2(0, 0) setget set_slots_offset
# Drag
export(bool) var draggable = true
export(bool) var hold_to_drag = false
export(Rect2) var drag_rect_transform = Rect2(Vector2(-16,-32), Vector2(64,16)) setget set_drag_rect_transform
# Items
export(bool) var drop_outside_slot = false

const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false

var drag_rect = preload("res://addons/inventory/helpers/drag_rect2.gd").new()

var slots = []
var items = []
var items_dropped = []

var drag_region
var dragging

var slot_mouse_over = false

var mouse_over = false

func _enter_tree():
	if not drag_rect.get_parent():
		add_child(drag_rect)
	set_drag_rect_transform(drag_rect_transform)
	drag_rect.color = RECT_COLOR_DRAG
	drag_rect.filled = RECT_FILLED
	__redo_slots()
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventories")
	drag_rect.connect("mouse_entered", self, "__rect_mouse_entered")
	drag_rect.connect("mouse_exited", self, "__rect_mouse_exited")
	
func __rect_mouse_entered(inst):
	mouse_over = true
	emit_signal("mouse_entered", self)
	
func __rect_mouse_exited(inst):
	mouse_over = false
	emit_signal("mouse_exited", self)
	
func __slot_mouse_entered(inst):
	slot_mouse_over = true
	emit_signal("slot_mouse_entered", inst)
	
func __slot_mouse_exited(inst):
	slot_mouse_over = false
	emit_signal("slot_mouse_exited", inst)
	
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
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var inst = custom_slot.instance()
			inst.inventory = self
			inst.position = Vector2(offset.x + x * slots_spacing.x,offset.y + y * slots_spacing.y)
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
		slots.pop_back().queue_free()
			
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
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var slot = slots[x+(y*slots_amount.x)]
			slot.position = Vector2(slots_offset.x + x * slots_spacing.x, slots_offset.y + y * slots_spacing.y)
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
	
func set_slots_offset(value):
	slots_offset = value
	_update_slots()
	
func set_slots_spacing(value):
	slots_spacing = value
	_update_slots()
	
func set_drag_rect_transform(value):
	drag_rect_transform = value
	drag_rect.rect = drag_rect_transform
	drag_rect.update()
	
func set_debug_in_game(value):
	debug_in_game = value
	drag_rect.debug_in_game = value
	_update_slots()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	drag_rect.debug_in_editor = value
	_update_slots()
	
func global_z_index():
	"""Return the total z_index of this instance and all of its ancestors combined"""
	var node = self
	var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	var total = 0
	while node != main:
		total += node.z_index
		node = node.get_parent()
	return total
	
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