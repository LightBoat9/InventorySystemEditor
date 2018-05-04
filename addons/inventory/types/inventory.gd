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

signal slot_mouse_entered
signal slot_mouse_exited

signal drag_rect_mouse_entered
signal drag_rect_mouse_exited

# Slots
export(GDScript) var custom_slot = preload("res://addons/inventory/types/inventory_slot.gd") setget set_custom_slot
export(Vector2) var slots_amount = Vector2(2, 2) setget set_slots_amount
export(Vector2) var slots_spacing = Vector2(32, 32) setget set_slots_spacing
export(Vector2) var slots_offset = Vector2(0, 0) setget set_slots_offset
# Drag
export(bool) var draggable = true setget set_draggable
export(bool) var hold_to_drag = false
export(Rect2) var drag_rect = Rect2(Vector2(-16,-32), Vector2(64,16)) setget set_drag_rect
# Items
# Remove the item from the inventory if dragged outside of it and dropped
export(bool) var items_drop_remove = false

var _drag_rect2 = preload("res://addons/inventory/helpers/drag_rect2.gd").new()

var slots = []

var items = []
var items_dropped = [] # Contains any items that were forced out of the inventory

var drag_region
var dragging

var child_script_instance
var _default_z_index

var slot_mouse_over = false

func _enter_tree():
	if not _drag_rect2.get_parent():
		add_child(_drag_rect2)
	set_drag_rect(drag_rect)
	_drag_rect2.color = RECT_COLOR_DRAG
	_drag_rect2.filled = RECT_FILLED
	add_to_group("inventories")
	_default_z_index = z_index
	_remove_slots()
	_add_slots()
	update()
	_update_slots()
	
func _ready():
	_drag_rect2.connect("mouse_entered", self, "_rect_mouse_entered")
	_drag_rect2.connect("mouse_exited", self, "_rect_mouse_exited")
	
func _not_custom_slot():
	if not custom_slot:
		printerr("Custom slot is null on %s (%s)" % [str(self), self.name])
		return true
	else:
		return false
	
## Private Methods
func _add_slots():
	if _not_custom_slot():
		return
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var inst = custom_slot.new()
			inst.inventory = self
			inst.position = Vector2(offset.x + x * slots_spacing.x,offset.y + y * slots_spacing.y)
			inst.connect("item_added", self, "_item_added")
			inst.connect("item_removed", self, "_item_removed")
			inst.connect("item_stack_changed", self, "_item_stack_changed")
			inst.connect("item_outside_slot", self, "_item_outside_slot")
			inst.connect("mouse_entered", self, "_slot_mouse_entered")
			inst.connect("mouse_exited", self, "_slot_mouse_exited")
			slots.append(inst)
			add_child(inst)
			
func _remove_slots():
	items.clear()
	while slots.size():
		var inst = slots.pop_back()
		if inst.item:
			inst.item.slot = null
			if inst.item.get_parent():
				inst.item.get_parent().remove_child(inst.item)
		if inst.get_parent():
			inst.get_parent().remove_child(inst)
			
func _rect_mouse_entered(inst):
	mouse_over = true
	emit_signal("drag_rect_mouse_entered", self)
	
func _rect_mouse_exited(inst):
	mouse_over = false
	emit_signal("drag_rect_mouse_exited", self)
		
func _update_slots():
	if _not_custom_slot():
		return
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var slot = slots[x+(y*slots_amount.x)]
			slot.position = Vector2(slots_offset.x + x * slots_spacing.x, slots_offset.y + y * slots_spacing.y)
			
func _item_added(item):
	if not items.has(item):
		items.append(item)
		emit_signal("item_added", item)
	else:
		emit_signal("item_moved", item)
	
func _item_removed(item):
	items.erase(item)
	emit_signal("item_removed", item)
	
func _item_stack_changed(item):
	# Remove deleted items
	for i in items:
		if i == item and item.stack == 0:
			items.remove(items.find(item))
	emit_signal("item_stack_changed", item)
	
func _item_outside_slot(item):
	if items_drop_remove and item.slot:
		if item in items:
			items.erase(item)
		item.remove_from_tree()
		items_dropped.append(item)
		emit_signal("item_dropped", item)
	
func _slot_mouse_entered(inst):
	slot_mouse_over = true
	emit_signal("slot_mouse_entered", inst)
	
func _slot_mouse_exited(inst):
	slot_mouse_over = false
	emit_signal("slot_mouse_exited", inst)
	
## Public Methods
func add_item(item):
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var slot = slots[x+(y*slots_amount.x)]
			if slot.item and slot.item.id == item.id:
				var overflow = slot.item.set_stack(slot.item.stack + item.stack)
				item.set_stack(overflow)
				if overflow == 0:
					return
			if not slot.item:
				slot.set_item(item)
				return
	items_dropped.append(item)
	emit_signal("item_dropped", item)
	
func add_items_from_array(arr):
	for slot in slots:
		if len(arr):
			var inst = arr.pop_front()
			slot.set_item(inst)
		else:
			break
	for item in arr:
		items_dropped.append(item)
		emit_signal("item_dropped", item)
		
func remove_all_items():
	var temp_items = items.duplicate()
	items.clear()
	return temp_items
			
func set_custom_slot(value):
	var temp_items = items.duplicate()
	_remove_slots()
	custom_slot = value
	_add_slots()
	_update_slots()
			
func set_slots_amount(value):
	var temp_items = remove_all_items()
	_remove_slots()
	slots_amount = value
	_add_slots()
	add_items_from_array(temp_items)
	_update_slots()
	
func set_slots_offset(value):
	slots_offset = value
	_update_slots()
	
func set_slots_spacing(value):
	slots_spacing = value
	_update_slots()
	
func set_drag_rect(value):
	drag_rect = value
	_drag_rect2.rect = drag_rect
	_drag_rect2.update()
	
func set_draggable(value):
	draggable = value