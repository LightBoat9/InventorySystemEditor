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
extends "res://addons/inventory/types/inventory_base.gd"
	
signal item_added
signal item_removed
signal item_stack_changed
	
export(bool) var debug_mode = false setget set_debug_mode
export(bool) var item_drag_return = true
export(Rect2) var drop_rect = Rect2(Vector2(-16,-16), Vector2(32, 32)) setget set_drop_rect
	
var _area_rect2 = AreaRect2.new()
var _default_texture = preload("res://addons/inventory/assets/slot.png")
var dragging = false
var inventory = null
var item = null
	
func apply_changes():
	print("TEST")
	
func _enter_tree():
	if not _area_rect2.get_parent():
		add_child(_area_rect2)
	_area_rect2.color = RECT_COLOR_AREA
	_area_rect2.filled = RECT_FILLED
	set_drop_rect(drop_rect)
	add_to_group("inventory_nodes")
	add_to_group("inventory_slots")
	
func _ready():
	_area_rect2.connect("mouse_entered", self, "__rect_mouse_entered")
	_area_rect2.connect("mouse_exited", self, "__rect_mouse_exited")
		
func __rect_mouse_entered(inst):
	mouse_over = true
	emit_signal("mouse_entered", self)
	
func __rect_mouse_exited(inst):
	mouse_over = false
	emit_signal("mouse_exited", self)
	
func __stack_changed(item):
	emit_signal("item_stack_changed", item)
	
func __item_outside_slot(item):
	emit_signal("item_outside_slot", item)
	
func set_item(item):
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
	
	if item.get_parent():
		item.get_parent().remove_child(item)
		
	item.position = item.drag_rect.position
	item.z_index = 0
	
	add_child(item)
	emit_signal("item_added", item)
	
func remove_item():
	"""Removes the item from the slot and returns it"""
	if not item:
		return

	item.slot = null
	
	var inst = item
	item = null
	return inst
	
func set_drop_rect(value):
	drop_rect = value
	_area_rect2.rect = drop_rect
	_area_rect2.update()
	
func swap_items(slot):
	if not (self.item and slot.item):
		return
	var temp = slot.remove_item()
	slot.set_item(remove_item())
	set_item(temp)
	
func set_debug_mode(value):
	debug_mode = value
	_area_rect2.debug_mode = value