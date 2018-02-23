tool
extends Sprite
	
export var draggable = true
onready var initial_parent = get_parent()
	
var _mouse_over = false
var _dragging = false
var _drop_z_index = 1

var slot = null
	
func _enter_tree():
	add_to_group("inventory_items")
	
func _ready():
	set_process_input(true)
	set_physics_process(true)
	
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
		z_index = max_z + 1
		return true
		
func _input(event):
	if event is InputEventMouseMotion:
		_mouse_over = _item_under_cursor()
	elif event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if _mouse_over and event.pressed and draggable:
				if _set_top_item_dragging():
					_dragging = true
					if slot:
						slot = null
			elif not event.pressed:
				if _dragging:
					add_to_inventory()
				_dragging = false
	
func _physics_process(delta):
	if _dragging:
		global_position = get_global_mouse_position()
		if not centered:
			global_position -= texture.get_size() / 2.0
	
func add_to_inventory():
	"""Adds the item into the inventory"""
	_drop_z_index = z_index
	if draggable:
		var p = get_viewport().get_mouse_position()
		
		for slot in get_tree().get_nodes_in_group("inventory_slots"):
			var a = slot.global_position
			var b = Vector2(slot.global_position.x + slot.texture.get_size().x, slot.global_position.y)
			var c = Vector2(slot.global_position.x + slot.texture.get_size().x, slot.global_position.y + slot.texture.get_size().y)
			if p.x >= a.x and p.x <= b.x and p.y >= a.y and p.y <= c.y:
				if not slot.item:
					slot.set_item(self)
				break
			
func remove_from_inventory():
	"""Adds the item back into the world"""
	# Add the item back to its starting parent
	initial_parent.add_child(self)
	z_index = _drop_z_index
	
	# Set the position to the mouse if the item is draggable
	if draggable:
		global_position = get_global_mouse_position()
		if not centered:
			global_position -= texture.get_size() / 2.0
		_dragging = true