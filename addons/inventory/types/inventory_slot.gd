"""
	* Caution * 
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new TextureRect and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory_slot.gd"
		
"""
tool
extends TextureRect
	
signal item_added(item)
signal item_removed(item)
signal item_stack_changed(item, amount)
signal global_mouse_entered
signal global_mouse_exited

export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
export(bool) var item_drag_return = true
	
var InventoryController = preload("res://addons/inventory/types/inventory_controller.gd").new()
var dragging = false
var inventory = null
var item = null setget set_item
var mouse_over = false
	
const RECT_COLOR = Color("3FC380")
const RECT_FILLED = false
	
func _ready():
	add_child(InventoryController)
	add_to_group("inventory_nodes")
	add_to_group("inventory_slots")
	
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
	
func set_item(inst):
	if not inst:
		print_stack()
		printerr("Cannot set null item on %s (%s)" % [str(self), self.name])
		return
	if not inst.is_in_group("inventory_items"):
		print_stack()
		printerr("Cannot set item with type %s (must be inventory_item)" % typeof(item))
		return
	if item:
		print_stack()
		printerr("Cannot set item when slot already contains an item")
		return
	item = inst
	if inst.slot:
		inst.slot.remove_item()
	inst.slot = self
	
	if inst.is_connected("stack_changed", self, "__stack_changed"):
		inst.connect("stack_changed", self, "__stack_changed")
	if inst.is_connected("drop_outside_slot", self, "__item_outside_slot"):
		inst.connect("drop_outside_slot", self, "__item_outside_slot")
		
	inst.rect_global_position = rect_global_position
	
	emit_signal("item_added", inst)
	
func move_item(slot):
	if not item:
		print_stack()
		printerr("Cannot move item when item is null")
		return
	if slot.item:
		swap_items(slot)
		return
	slot.item = item
	item.slot = slot
	item = null
	
func clear_item():
	item.slot = null
	item = null
	
func remove_item():
	"""Removes the item from the slot and returns it"""
	item.slot = null
	var inst = item
	emit_signal("item_removed", item)
	item = null
	return inst
	
func swap_items(slot):
	if not (self.item and slot.item):
		print_stack()
		printerr("Cannot swap items with slot one slot does not contain an item")
		return
	var temp_self = item
	var temp_other = slot.item
	slot.clear_item()
	clear_item()
	slot.set_item(temp_self)
	set_item(temp_other)
	
func set_debug_in_game(value):
	debug_in_game = value
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	update()