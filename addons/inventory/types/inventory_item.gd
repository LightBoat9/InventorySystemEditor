tool
extends Sprite
	
export var draggable = true
	
onready var initial_parent = get_parent()
	
var _mouse_over = false
var _dragging = false
	
var slot = null
	
func _ready():
	set_process_input(true)
	set_physics_process(true)
	
func _is_point_inside_sprite(p):
	var a = global_position
	var b = Vector2(global_position.x + texture.get_size().x, global_position.y)
	var c = Vector2(global_position.x + texture.get_size().x, global_position.y + texture.get_size().y)
	
	if p.x >= a.x and p.x <= b.x and p.y >= a.y and p.y <= c.y:
		return true
	else:
		return false
	
func _input(event):
	if event is InputEventMouseMotion:
		_mouse_over = _is_point_inside_sprite(event.global_position)
	elif event is InputEventMouseButton: 
		if event.button_index == BUTTON_LEFT:
			if _mouse_over and event.pressed and draggable:
				_dragging = true
				if slot:
					slot = null
					scale = Vector2(1,1)
					get_parent().remove_child(self)
					initial_parent.add_child(self)
			elif not event.pressed:
				_dragging = false
				_drop()
	
func _physics_process(delta):
	if _dragging:
		global_position = get_viewport().get_mouse_position()
		if not centered:
			global_position -= texture.get_size() / 2.0
	
func _drop():
	var p = get_viewport().get_mouse_position()
	
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		var a = slot.global_position
		var b = Vector2(slot.global_position.x + slot.texture.get_size().x, slot.global_position.y)
		var c = Vector2(slot.global_position.x + slot.texture.get_size().x, slot.global_position.y + slot.texture.get_size().y)
		if p.x >= a.x and p.x <= b.x and p.y >= a.y and p.y <= c.y:
			slot.set_item(self)
			break