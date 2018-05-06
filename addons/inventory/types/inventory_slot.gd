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
signal mouse_entered
signal mouse_exited
	
export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
export(bool) var item_drag_return = true
export(Rect2) var area_rect_transform = Rect2(Vector2(-16,-16), Vector2(32, 32)) setget set_area_rect_transform
	
var area_rect = preload("res://addons/inventory/helpers/area_rect2.gd").new()
var _default_texture = preload("res://addons/inventory/assets/slot.png")
var dragging = false
var inventory = null
var item = null
	
var mouse_over = false

const RECT_COLOR_AREA = Color("3FC380")
const RECT_FILLED = false
	
func _enter_tree():
	if not area_rect.get_parent():
		add_child(area_rect)
	area_rect.color = RECT_COLOR_AREA
	area_rect.filled = RECT_FILLED
	set_area_rect_transform(area_rect_transform)
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventory_slots")
	area_rect.connect("mouse_entered", self, "__rect_mouse_entered")
	area_rect.connect("mouse_exited", self, "__rect_mouse_exited")
		
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
	
	if item.get_parent():
		item.get_parent().remove_child(item)
		
	item.position = -item.drag_rect.rect.position * item.scale + area_rect.rect.position * scale
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
	
func set_area_rect_transform(value):
	area_rect_transform = value
	area_rect.rect = area_rect_transform
	area_rect.update()
	
func swap_items(slot):
	if not (self.item and slot.item):
		return
	var temp = slot.remove_item()
	slot.set_item(remove_item())
	set_item(temp)
	
func set_debug_in_game(value):
	debug_in_game = value
	area_rect.debug_in_game = value
	
func set_debug_in_editor(value):
	debug_in_editor = value
	area_rect.debug_in_editor = value
	
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