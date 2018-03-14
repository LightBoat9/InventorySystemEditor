tool
extends TextureRect
	
signal item_added
signal item_removed
	
var _mouse_over = false
	
var InventoryItem = load("res://addons/inventory/types/inventory_item.gd")
	
export var scale_item_sprite = true

var item_sprite
var item = null
	
func _enter_tree():
	add_to_group("inventory_slots")
	texture = load("res://addons/inventory/assets/slot.png")
	_init_item_texture()
	set_process_input(true)
	set_process(true)
	
func _input(event):
	if event is InputEventMouseMotion:
		if item:
			_mouse_over = _item_under_cursor()
	elif event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if item and _mouse_over and event.pressed:
				if _set_top_item_dragging():
					emit_signal("item_removed", item)
					item.remove_from_inventory()
					item_sprite.texture = null
					item = null
				
func _item_under_cursor():
	var p = get_global_mouse_position()
	var a = global_position
	var b = Vector2(global_position.x + texture.get_size().x, global_position.y)
	var c = Vector2(global_position.x + texture.get_size().x, global_position.y + texture.get_size().y)
	if centered:
		a -= texture.get_size() / 2.0
		b -= texture.get_size() / 2.0
		c -= texture.get_size() / 2.0
	
	if p.x >= a.x and p.x <= b.x and p.y >= a.y and p.y <= c.y:
		return true
	else:
		return false
		
func _set_top_item_dragging():
	var top_item = self
	var max_z = z_index
	for item in get_tree().get_nodes_in_group("inventory_items"):
		if item.z_index > max_z:
			max_z = item.z_index
		if item._mouse_over and item.z_index > top_item.z_index:
			top_item = item
	if top_item == self:
		return true
	
func _init_item_texture():
	item_sprite = Sprite.new()
	item_sprite.z_index = z_index + 1
	item_sprite.centered = false
	add_child(item_sprite)
	
func set_item(item):
	self.item = item
	item.position = Vector2()
	item.z_index = z_index + 1
	
	if scale_item_sprite:
		item_sprite.scale = texture.get_size() / item.texture.get_size()
	
	item.slot = self
	if item.get_parent():
		item.get_parent().remove_child(item)
	item_sprite.texture = item.texture
	
	emit_signal("item_added", item)