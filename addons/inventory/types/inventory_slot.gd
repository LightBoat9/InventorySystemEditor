tool
extends Sprite
	
signal item_added
signal item_removed
signal item_stack_changed
	
export(bool) var modulate_on_hover = true
export(Color) var hover_modulate = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
export(Texture) var overlay = null setget set_overlay
	
var mouse_over = false
var _default_modulate
	
var InventoryItem = load("res://addons/inventory/types/inventory_item.gd")
	
var item = null
	
func _enter_tree():
	_default_modulate = modulate
	add_to_group("inventory_slots")
	set_process_input(true)
	set_process(true)
	
func _draw():
	if overlay:
		draw_texture(overlay, Vector2(0,0))
	
func _input(event):
	if event is InputEventMouseMotion:
		if texture:
			mouse_over = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale)
		modulate = hover_modulate if mouse_over and modulate_on_hover else _default_modulate
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if item and mouse_over and event.pressed:
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
				
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1)):
	return (
		mouse_pos.x >= rect_pos.x and 
		mouse_pos.x <= rect_pos.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y and 
		mouse_pos.y <= rect_pos.y + size.y * scale.y
		)
				
func set_item(item):
	self.item = item
	
	item.slot = self
	if not item.is_connected("stack_changed", self, "_stack_changed"):
		item.connect("stack_changed", self, "_stack_changed")
	
	if item.get_parent():
		item.get_parent().remove_child(item)
	
	if item.centered and texture:
		item.position = Vector2() + ((item.texture.get_size()*item.scale) / 2)
	else:
		item.position = Vector2()
	add_child(item)
	
	emit_signal("item_added", item)
	
func remove_item():
	"""Removes the item from the slot and returns it"""
	if not item:
		return

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