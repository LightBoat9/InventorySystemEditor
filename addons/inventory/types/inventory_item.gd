"""
	* Caution * 
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Sprite and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory_item.gd"
		
"""
tool
extends "res://addons/inventory/types/inventory_base.gd"
	
signal drag_started
signal drag_stopped
signal drop_outside_slot
signal stack_changed
	
# Properties
export var id = 0
# Drag
export(bool) var draggable = true setget set_draggable
export(bool) var hold_to_drag = false setget set_hold_to_drag
export(Rect2) var drag_rect = Rect2(Vector2(-32,-32), Vector2(64,64)) setget set_drag_rect
# Stack
export(bool) var stackable = true
export(int) var stack = 1 setget set_stack
export(int) var max_stack = 99 setget set_max_stack
export(bool) var remove_if_empty = true

var dragging = false setget set_dragging
var _drag_rect2 = preload("res://addons/inventory/helpers/drag_rect2.gd").new()
var slot = null
	
func _enter_tree():
	if not _drag_rect2.get_parent():
		add_child(_drag_rect2)
	_drag_rect2.color = RECT_COLOR_DRAG
	_drag_rect2.filled = RECT_FILLED
	set_drag_rect(drag_rect)
	add_to_group("inventory_items")
	
func _ready():
	_drag_rect2.connect("mouse_entered", self, "_rect_mouse_entered")
	_drag_rect2.connect("mouse_exited", self, "_rect_mouse_exited")
	_drag_rect2.connect("drag_started", self, "__drag_started")
	_drag_rect2.connect("drag_stopped", self, "__drag_stopped")
	
func _rect_mouse_entered(inst):
	mouse_over = true
	emit_signal("mouse_entered", self)
	
func _rect_mouse_exited(inst):
	mouse_over = false
	emit_signal("mouse_exited", self)
	
func __drag_started(x):
	dragging = true
	make_top()
	emit_signal("drag_started", self)
	
func __drag_stopped(x):
	dragging = false
	__drop()
	
func __drop():
	var top = top_node()
	if top:
		if top.is_in_group("inventory_slots"):
			if top.item: 
				if top.item != self and self.slot:
					__drop_swap(top)
			else:
				top.set_item(self)
		elif top.is_in_group("inventory_items"):
			if top.id == self.id:
				set_stack(top.add_stack(stack))
			elif top.slot and top != self and self.slot:
				__drop_swap(top.slot)
				
	if slot:
		if not top or not top.is_in_group("inventory_slots"):
			emit_signal("drop_outside_slot", self)
		position = -_drag_rect2.rect.position * scale + slot._area_rect2.rect.position * slot.scale
		z_index = 0
	emit_signal("drag_stopped", self)
	
func __drop_swap(slot):
	if slot.item != self and self.slot:
		var temp_item = slot.item
		slot.swap_items(self.slot)
		if not hold_to_drag:
			temp_item.set_dragging(true)
		temp_item._drag_rect2._mouse_relative = _drag_rect2._mouse_relative
		temp_item._drag_rect2.dragging_update()
	
func free():
	"""Overides Object.free to ensure references to the item are removed"""
	if slot:
		slot.remove_item()
	.free()
	
func queue_free():
	"""Overides Node.queue_free to ensure references to the item are removed"""
	if slot:
		slot.remove_item()
	.queue_free()
	
func set_draggable(value):
	draggable = value
	_drag_rect2.draggable = value
	
func set_hold_to_drag(value):
	hold_to_drag = value
	_drag_rect2.hold_to_drag = value
	
func add_stack(value):
	"""
	Adds the value to stack. Return any overflow above 
	max_stack or null if the item is not stackable
	"""
	if not stackable:
		return
	return set_stack(stack + value)
	
func set_stack(value):
	"""
	Set the value of stack. Return any overflow above 
	max_stack or null if the item is not stackable
	"""
	if not stackable:
		return
	var overflow = 0
	stack = value
	if stack > max_stack:
		overflow = stack - max_stack
		stack = max_stack
	if stack <= 0 and remove_if_empty:
		queue_free()
	emit_signal("stack_changed", self)
	return overflow
	
func set_max_stack(value):
	max_stack = value
	if stack > max_stack:
		set_stack(max_stack)
		
func set_drag_rect(value):
	drag_rect = value
	_drag_rect2.rect = drag_rect
	_drag_rect2.update()
	
func set_dragging(value):
	dragging = value
	_drag_rect2.dragging = value
	