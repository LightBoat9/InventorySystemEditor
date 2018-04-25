tool
extends "res://addons/inventory/types/inventory_base.gd"

signal drag_start
signal drag_stop
signal drag_outside_slot
signal stack_changed
# Mouse signals
signal mouse_enter
signal mouse_exit

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
	
	
onready var world_parent = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
var mouse_over = false
var dragging = false setget set_dragging
var drag_start_position = Vector2()
	
var slot = null
var return_slot = null

var _skip_mouse_click = false
	
func _enter_tree():
	add_to_group("inventory_nodes")
	add_to_group("inventory_items")
	
func _input(event):
	if event is InputEventMouseMotion and texture:
		var last_mouse_over = mouse_over
		mouse_over = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale, centered)
		if not last_mouse_over and mouse_over:
			emit_signal("mouse_enter", self)
		elif last_mouse_over and not mouse_over:
			emit_signal("mouse_exit", self)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if _skip_mouse_click:
			_skip_mouse_click = false
		elif draggable:
			if dragging:
				if hold_to_drag and not event.pressed or not hold_to_drag and event.pressed:
					set_dragging(false)
			elif not slot and event.pressed and mouse_over and _is_top_z():
				set_dragging(true)
	
func _physics_process(delta):
	if dragging and draggable:
		if not centered:
			global_position = get_global_mouse_position() - (texture.get_size() * scale) / 2
		else:
			global_position = get_global_mouse_position()
			
func _drop():
	for inst in get_tree().get_nodes_in_group("inventory_slots"):
		if inst.mouse_over and inst._is_top_z_slot():
			if not inst.item:  # Add item if slot is empty
				slot = inst
				slot._skip_mouse_click = true
				inst.remove_item()
				slot.set_item(self)
				return_slot = null
				return
			if inst.item and inst.item.id == id:  # Stack with item if it is the same
				inst._skip_mouse_click = true
				var overflow = inst.item.set_stack(inst.item.stack + stack)
				if overflow:
					if return_slot and not return_slot.item and hold_to_drag:
						return_slot.set_item(self)
					elif not hold_to_drag:
						dragging = true
				set_stack(overflow)
				return_slot = null
				return
			elif inst.item and return_slot and not return_slot.item and hold_to_drag:  # Swap items if the slots are available
				inst._skip_mouse_click = true
				var removed = inst.remove_item()
				removed.slot = return_slot
				return_slot.set_item(removed)
				slot = inst
				inst.set_item(self)
				return_slot = null
				return
			elif inst.item and not hold_to_drag:
				slot = inst
				var remove = slot.remove_item()
				remove._skip_mouse_click = true
				remove.dragging = true
				slot.set_item(self)
				return_slot = null
				return
	for inst in get_tree().get_nodes_in_group("inventory_items"):
		if inst != self and inst.mouse_over: 
			if inst.id == id:
				set_stack(inst.set_stack(inst.stack + stack))
				global_position = drag_start_position
				inst._skip_mouse_click = true
				return
	if stack > 0 and return_slot and not return_slot.item:
		return_slot.set_item(self)
		return_slot = null
		emit_signal("drag_outside_slot", self)
	
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1), is_centered=false):
	var ofs = Vector2()
	if is_centered:
		ofs = size*scale/2
	return (
		mouse_pos.x >= rect_pos.x - ofs.x and 
		mouse_pos.x <= rect_pos.x - ofs.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y - ofs.y and 
		mouse_pos.y <= rect_pos.y - ofs.y + size.y * scale.y
		)
	
func _drag_start():
	drag_start_position = global_position
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		if inst != self and inst.dragging:
			if inst.z_index <= z_index:
				inst.set_dragging(false)
			else:
				set_dragging(false)
				return
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		z_index = max(z_index, inst.z_index)
	z_index += 1
	emit_signal("drag_start")
	
func _is_top_z():
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		if inst.mouse_over and inst.z_index > z_index:
			return false
	return true
	
func remove_from_tree():
	if slot:
		slot.remove_item()
	slot = null
	return_slot = null
	get_parent().remove_child(self)
	
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
	
func set_dragging(value):
	dragging = value
	if dragging:
		_drag_start()
		emit_signal("drag_start")
	else:
		_drop()
		emit_signal("drag_stop")