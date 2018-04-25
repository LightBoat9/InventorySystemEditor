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
signal item_outside_slot  # Called when this item is dragged outside of its slot and dropped
signal item_stack_changed
	
export(bool) var hover_modulate = true
export(bool) var item_drag_return = true
export(Color) var modulate_color = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
export(Texture) var overlay = null setget set_overlay
	
var _default_modulate
var _default_texture = load("res://addons/inventory/assets/slot.png")
var dragging = false
	
var inventory = null
var item = null
	
var _skip_mouse_click = false
	
func _enter_tree():
	add_to_group("inventory_nodes")
	add_to_group("inventory_slots")
	if _default_texture:
		texture = _default_texture
	_default_texture = null
	_default_modulate = modulate
	
func _draw():
	if overlay:
		draw_texture(overlay, Vector2(0,0))
	
func _input(event):
	if event is InputEventMouseMotion and texture:
		var last_mouse_over = mouse_over
		mouse_over = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale, centered)
		if not last_mouse_over and mouse_over:
			emit_signal("mouse_enter", self)
		elif last_mouse_over and not mouse_over:
			emit_signal("mouse_exit", self)
		# Set modulate
		modulate = modulate_color if mouse_over and hover_modulate else _default_modulate
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if _skip_mouse_click:
				_skip_mouse_click = false
			elif item and mouse_over and event.pressed and _is_top_z() and _is_top_z_slot():
				if item.get_parent():
					item.get_parent().remove_child(item)
				var inst = remove_item()
				inst.world_parent.add_child(inst)
				inst.dragging = true
				if not inst.centered:
					inst.global_position = get_global_mouse_position() - (inst.texture.get_size() * inst.scale) / 2
				else:
					inst.global_position = get_global_mouse_position()
				emit_signal("item_removed", inst)
				
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
		
func _relative_z_index():
	if not inventory:
		return z_index
	else:
		return z_index + inventory.z_index
		
func _is_top_z_slot():
	for inst in get_tree().get_nodes_in_group("inventory_slots"):
		if inst.mouse_over and inst._relative_z_index() > _relative_z_index():
			return false
	return true
	
func _is_top_z():
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		if inst.mouse_over and inst.z_index > z_index:
			return false
	return true
				
func set_item(item):
	self.item = item
	item.z_index = z_index
	item.slot = self
	
	if not item.is_connected("stack_changed", self, "_stack_changed"):
		item.connect("stack_changed", self, "_stack_changed")
	
	if item.get_parent():
		item.get_parent().remove_child(item)
		
	item.connect("drag_outside_slot", self, "_item_outside_slot")
		
	if item.centered and not centered and item.texture:
		item.position = Vector2() + ((item.texture.get_size() * item.scale) / 2)
	elif not item.centered and centered and texture:
		item.position = Vector2() - ((texture.get_size() * scale) / 2)
	else:
		item.position = Vector2()
	
	add_child(item)
	emit_signal("item_added", item)
	
func remove_item():
	"""Removes the item from the slot and returns it"""
	if not item:
		return

	item.disconnect("drag_outside_slot", self, "_item_outside_slot")
	if item_drag_return:
		item.return_slot = self
	item.slot = null
	
	var inst = item
	item = null
	return inst
	
func set_overlay(value):
	overlay = value
	update()
	
func _stack_changed(item):
	emit_signal("item_stack_changed", item)
	
func _item_outside_slot(item):
	emit_signal("item_outside_slot", item)