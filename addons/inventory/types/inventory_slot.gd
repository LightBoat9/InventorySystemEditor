tool
extends TextureRect
	
signal item_added
signal item_removed
	
export(Color) var hover_modulate = Color(230.0/255.0,230.0/255.0,230.0/255.0,1)
export(bool) var scale_item = false
export(Texture) var overlay = null setget set_overlay
	
var _default_modulate
	
var mouse_over = false

var _default_scale
	
var InventoryItem = load("res://addons/inventory/types/inventory_item.gd")
	
var item = null
	
func _enter_tree():
	_default_modulate = modulate
	add_to_group("inventory_slots")
	set_process_input(true)
	set_process(true)
	
func _ready():
	_default_scale = rect_scale
	
func _draw():
	if overlay:
		draw_texture(overlay, Vector2(0,0))
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = (
			event.global_position.x >= rect_global_position.x and event.position.x <= rect_global_position.x + texture.get_size().x and
			event.global_position.y >= rect_global_position.y and event.position.y <= rect_global_position.y + texture.get_size().y
			)
		if mouse_over:
			modulate = hover_modulate
		else:
			modulate = _default_modulate
	if event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if item and mouse_over and event.pressed:
				if item.get_parent():
					item.get_parent().remove_child(item)
				item.rect_scale = _default_scale
				item.remove_from_slot()
				item.rect_position = get_global_mouse_position() - item.rect_size / 2
				item = null
				emit_signal("item_removed", item)
	
func set_item(item):
	if not self.item:
		self.item = item
		self.item.set_as_toplevel(false)
		item.rect_position = Vector2()
		
		if scale_item:
			item.rect_scale = Vector2(1,1)
			item.rect_size = texture.get_size()
			item.expand = true
			item.stretch_mode = STRETCH_SCALE
		
		item.slot = self
		if item.get_parent():
			item.get_parent().remove_child(item)
		item.rect_position = Vector2()
		add_child(item)
		
		emit_signal("item_added", item)
	
func set_overlay(value):
	overlay = value
	update()