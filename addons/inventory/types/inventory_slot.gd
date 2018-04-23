tool
extends Sprite
	
signal item_added
signal item_removed
signal item_stack_changed
signal item_outside_slot
signal mouse_over
	
export(bool) var hover_modulate = true
export(Color) var modulate_color = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
export(Texture) var overlay = null setget set_overlay
	
var mouse_over = false
var _default_modulate
	
var item = null
	
var _skip_mouse_click = false
	
func _enter_tree():
	_default_modulate = modulate
	add_to_group("inventory_slots")
	
func _draw():
	if overlay:
		draw_texture(overlay, Vector2(0,0))
	
func _input(event):
	if event is InputEventMouseMotion:
		if texture:
			mouse_over = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale, centered)
		if mouse_over:
			emit_signal("mouse_over", self)
		modulate = modulate_color if mouse_over and hover_modulate else _default_modulate
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if _skip_mouse_click:
				_skip_mouse_click = false
			elif item and mouse_over and event.pressed and item._is_top_item():
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
				
func set_item(item):
	self.item = item
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