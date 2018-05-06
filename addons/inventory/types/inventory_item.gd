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
signal mouse_entered
signal mouse_exited
	
export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Properties
export var id = 0
# Drag
export(bool) var draggable = true setget set_draggable
export(bool) var hold_to_drag = false setget set_hold_to_drag
export(Rect2) var drag_rect_transform = Rect2(Vector2(-32,-32), Vector2(64,64)) setget set_drag_rect_transform
# Stack
export(bool) var stackable = true
export(int) var stack = 1 setget set_stack
export(int) var max_stack = 99 setget set_max_stack
export(bool) var remove_if_empty = true
	
var drag_rect = preload("res://addons/inventory/helpers/drag_rect2.gd").new()
var dragging = false setget set_dragging
var slot = null

var mouse_over = false

const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false
	
func _enter_tree():
	if not drag_rect.get_parent():
		add_child(drag_rect)
	drag_rect.color = RECT_COLOR_DRAG
	drag_rect.filled = RECT_FILLED
	set_drag_rect_transform(drag_rect_transform)
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventory_items")
	drag_rect.connect("mouse_entered", self, "_rect_mouse_entered")
	drag_rect.connect("mouse_exited", self, "_rect_mouse_exited")
	drag_rect.connect("drag_started", self, "__drag_started")
	drag_rect.connect("drag_stopped", self, "__drag_stopped")
	
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
			if top.item and top.item != self:
				if top.item.id == self.id:
					set_stack(top.item.add_stack(stack))
				elif self.slot:
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
		position = -drag_rect.rect.position * scale + slot.area_rect.rect.position * slot.scale
		z_index = 0
	emit_signal("drag_stopped", self)
	
func __drop_swap(slot):
	if slot.item != self and self.slot:
		var temp_item = slot.item
		slot.swap_items(self.slot)
		if not hold_to_drag:
			temp_item.set_dragging(true)
		temp_item.drag_rect._mouse_relative = drag_rect._mouse_relative
		temp_item.drag_rect.dragging_update()
	
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
	
func remove_from_tree():
	if slot:
		slot.remove_item()
	if get_parent():
		get_parent().remove_child(self)
		
func set_draggable(value):
	draggable = value
	drag_rect.draggable = value
	
func set_hold_to_drag(value):
	hold_to_drag = value
	drag_rect.hold_to_drag = value
	
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
		
func set_drag_rect_transform(value):
	drag_rect_transform = value
	drag_rect.rect = drag_rect_transform
	drag_rect.update()
	
func set_dragging(value):
	dragging = value
	drag_rect.dragging = value
	
func set_debug_in_game(value):
	debug_in_game = value
	drag_rect.debug_in_game = value
	
func set_debug_in_editor(value):
	debug_in_editor = value
	drag_rect.debug_in_editor = value
	
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