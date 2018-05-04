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
signal drag_outside_slot
signal stack_changed

signal mouse_entered
signal mouse_exited
	
# Properties
export var id = 0
# Drag
export(bool) var draggable = true
export(bool) var hold_to_drag = false
# Stack
export(bool) var stackable = true
export(int) var stack = 1 setget set_stack
export(int) var max_stack = 99 setget set_max_stack
export(bool) var remove_if_empty = true

var dragging = false setget set_dragging
export(Rect2) var drag_rect = Rect2(Vector2(-32,-32), Vector2(64,64)) setget set_drag_rect
var _drag_rect2 = preload("res://addons/inventory/helpers/drag_rect2.gd").new()

var slot = null
var return_slot = null

var _skip_mouse_click = false
	
func _enter_tree():
	if not _drag_rect2.get_parent():
		add_child(_drag_rect2)
	_drag_rect2.color = RECT_COLOR_DRAG
	_drag_rect2.filled = RECT_FILLED
	set_drag_rect(drag_rect)
	add_to_group("inventory_nodes")
	add_to_group("inventory_items")
	
func _ready():
	_drag_rect2.connect("mouse_entered", self, "_rect_mouse_entered")
	_drag_rect2.connect("mouse_exited", self, "_rect_mouse_exited")
	_drag_rect2.connect("drag_started", self, "_rect_drag_started")
	_drag_rect2.connect("drag_stopped", self, "_rect_drag_stopped")
				
func _rect_mouse_entered(inst):
	emit_signal("mouse_entered", self)
	
func _rect_mouse_exited(inst):
	emit_signal("mouse_exited", self)
	
func set_stack(value):
	var overflow = 0
	stack = value
	if stack > max_stack:
		overflow = stack - max_stack
		stack = max_stack
	if stack <= 0 and remove_if_empty:
		if slot:
			slot.remove_item()
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
	_drag_rect2.update()
	
func _rect_drag_started(x):
	dragging = true
	make_top()
	emit_signal("drag_started", self)
	
func _rect_drag_stopped(x):
	dragging = false
	var top = top()
	if top:
		if top.is_in_group("inventory_slots"):
			if top.item:
				if top.item != self and self.slot:
					var temp_item = top.item
					top.swap_items(self.slot)
					temp_item.set_dragging(true)
					temp_item._drag_rect2._mouse_relative = _drag_rect2._mouse_relative
					temp_item._drag_rect2.dragging_update()
			else:
				top.set_item(self)
		elif top.is_in_group("inventory_items"):
			if top != self and not top.slot:
				pass
	
	if slot:
		position = Vector2()
		z_index = 0
	emit_signal("drag_stopped", self)
	
func set_dragging(value):
	dragging = value
	_drag_rect2.dragging = value