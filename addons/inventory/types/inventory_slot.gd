tool
extends TextureRect
	
signal item_added
signal item_removed
	
export(Color) var hover_modulate = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
export(bool) var scale_item = false
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
		mouse_over = _mouse_in_rect(event.global_position, rect_global_position, texture.get_size(), rect_scale)
		modulate = hover_modulate if mouse_over else _default_modulate
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if item and mouse_over and event.pressed:
				if item.get_parent():
					item.get_parent().remove_child(item)
				item.remove_from_slot()
				item.rect_position = get_global_mouse_position() - item.rect_size / 2
				item = null
				emit_signal("item_removed", item)
				
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1)):
	return (
		mouse_pos.x >= rect_pos.x and 
		mouse_pos.x <= rect_pos.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y and 
		mouse_pos.y <= rect_pos.y + size.y * scale.y
		)
				
func set_item(item):
	if not self.item:
		self.item = item
		
		item.rect_position = Vector2()
		item.slot = self
		
		if item.get_parent():
			item.get_parent().remove_child(item)
		
		item.rect_position = Vector2()
		add_child(item)
		
		emit_signal("item_added", item)
	
func set_overlay(value):
	overlay = value
	update()