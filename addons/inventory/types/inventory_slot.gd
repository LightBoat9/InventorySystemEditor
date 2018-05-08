"""
	* Caution * 
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Sprite and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory_slot.gd"
		
"""
tool
extends TextureRect
	
signal item_added
signal item_removed
signal item_stack_changed
signal global_mouse_entered
signal global_mouse_exited

export(bool) var debug_in_game = true setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
export(bool) var item_drag_return = true
	
var dragging = false
var inventory = null
var item = null
var mouse_over = false
	
const RECT_COLOR = Color("3FC380")
const RECT_FILLED = false
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventory_slots")
	
func _input(event):
	if event is InputEventMouseMotion:
		var last_mouse_over = mouse_over
		mouse_over = _mouse_in_rect(event.global_position, rect_global_position * rect_scale, rect_size * rect_scale)
		if not last_mouse_over and mouse_over:
			emit_signal("global_mouse_entered")
		elif last_mouse_over and not mouse_over:
			emit_signal("global_mouse_exited")
	
func _draw():
	if (debug_in_editor and Engine.editor_hint) or debug_in_game:
		draw_rect(Rect2(Vector2(), get_rect().size), RECT_COLOR, RECT_FILLED)
		
func _mouse_in_rect(mouse_pos, rect_pos, rect_size):
	return (mouse_pos.x >= rect_pos.x and mouse_pos.x <= rect_pos.x + rect_size.x and
			mouse_pos.y >= rect_pos.y and mouse_pos.y <= rect_pos.y + rect_size.y)
	
func __stack_changed(item):
	emit_signal("item_stack_changed", item)
	
func __item_outside_slot(item):
	emit_signal("item_outside_slot", item)
	
func free():
	if item:
		item.free()
	.queue_free()
	
func queue_free():
	if item:
		item.queue_free()
	.queue_free()
	
func set_item(item):
	if not item:
		print_stack()
		printerr("Cannot set null item on %s (%s)" % [str(self), self.name])
		return
	if not item.is_in_group("inventory_items"):
		print_stack()
		printerr("Cannot set item with type %s (must be inventory_item)" % typeof(item))
		return
	if self.item:
		remove_item()
	self.item = item
	if item.slot:
		item.slot.remove_item()
	item.slot = self
	
	if item.is_connected("stack_changed", self, "__stack_changed"):
		item.connect("stack_changed", self, "__stack_changed")
	if item.is_connected("drop_outside_slot", self, "__item_outside_slot"):
		item.connect("drop_outside_slot", self, "__item_outside_slot")
		
	item.rect_global_position = rect_global_position
	
	emit_signal("item_added", item)
	
func remove_item():
	"""Removes the item from the slot and returns it"""
	if not item:
		return

	item.slot = null
	
	var inst = item
	item = null
	return inst
	
func swap_items(slot):
	if not (self.item and slot.item):
		return
	var temp = slot.remove_item()
	slot.set_item(remove_item())
	set_item(temp)
	
func set_debug_in_game(value):
	debug_in_game = value
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	update()