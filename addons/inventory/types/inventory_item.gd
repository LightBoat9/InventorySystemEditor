tool
extends Sprite

signal drag_start
signal drag_stop
signal drag_outside_slot
signal stack_changed

# Property Exports
export var id = 0
# Drag Exports
export(bool) var draggable = true
export(bool) var hold_to_drag = false
export(bool) var drag_overlap = true
# Stack Exports
export(bool) var stackable = true
export(bool) var stack_label_show = true setget set_stack_label_show
export(int) var stack = 1 setget set_stack
export(Vector2) var stack_label_position = Vector2(24, 24) setget set_stack_label_position
export(int) var max_stack = 99
	
onready var world_parent = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
var mouse_over = false
var dragging = false setget set_dragging
var drag_start_position = Vector2()
	
var slot = null
var return_slot = null
	
var stack_label = Label.new()

var _skip_mouse_click = false
	
func _enter_tree():
	_update_stack_label()
	if not stack_label.get_parent():
		add_child(stack_label)
	add_to_group("inventory_items")
	
func _ready():
	add_to_group("inventory_dragabbles")
	
func _input(event):
	if event is InputEventMouseMotion and texture:
		mouse_over = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale, centered)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if _skip_mouse_click:
			_skip_mouse_click = false
		elif draggable:
			if dragging:
				if hold_to_drag and not event.pressed or not hold_to_drag and event.pressed:
					set_dragging(false)
					emit_signal("drag_stop")
			elif not slot and event.pressed and mouse_over and _is_top_item():
				set_dragging(true)
	
func _physics_process(delta):
	if dragging and draggable:
		if not centered:
			global_position = get_global_mouse_position() - (texture.get_size() * scale) / 2
		else:
			global_position = get_global_mouse_position()
			
func _drop():
	for inst in get_tree().get_nodes_in_group("inventory_slots"):
		if inst.mouse_over:
			# Drop self or stack with other item
			if inst.item and inst.item.id == id:
				inst._skip_mouse_click = true
				var overflow = inst.item.set_stack(inst.item.stack + stack)
				if stack > 0 and return_slot and not return_slot.item and overflow:
					return_slot.set_item(self)
				set_stack(overflow)
				return_slot = null
				return
			elif inst.item and return_slot:
				inst._skip_mouse_click = true
				return_slot.set_item(inst.remove_item())
				inst.set_item(self)
				return_slot = null
				return
			# Add self to slot
			elif not inst.item or inst.item and not hold_to_drag:
				inst.remove_item()
				slot = inst
				slot._skip_mouse_click = true
				slot.set_item(self)
				return_slot = null
				return
	for inst in get_tree().get_nodes_in_group("inventory_items"):
		if inst != self and inst.mouse_over: 
			if inst.id == id:
				set_stack(inst.set_stack(inst.stack + stack))
				global_position = drag_start_position
				inst._skip_mouse_click = true
				return
	if stack > 0 and return_slot and not return_slot.item:
		return_slot.set_item(self)
		return_slot = null
		emit_signal("drag_outside_slot", self)
	
func _update_stack_label():
	if stack_label_show:
		stack_label.show()
	else:
		stack_label.hide()
	stack_label.text = str(stack)
	stack_label.rect_position = stack_label_position
	
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
	
func _drag_init():
	drag_start_position = global_position
	for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
		if inst != self and inst.dragging:
			if inst.z_index <= z_index:
				inst.set_dragging(false)
			else:
				set_dragging(false)
				return
	if drag_overlap:
		for inst in get_tree().get_nodes_in_group("inventory_items"):
			z_index = max(z_index, inst.z_index)
		z_index += 1
	emit_signal("drag_start")
	
func set_stack(amount):
	var overflow = 0
	stack = amount
	if stack > max_stack:
		overflow = stack - max_stack
		stack = max_stack
	if stack <= 0:
		if slot:
			slot.remove_item()
		queue_free()
	_update_stack_label()
	emit_signal("stack_changed", self)
	return overflow
	
func set_dragging(value):
	dragging = value
	if dragging:
		_drag_init()
	else:
		_drop()
		
func _is_top_item():
	for inst in get_tree().get_nodes_in_group("inventory_items"):
		if inst.mouse_over and inst.z_index > z_index:
			return false
	return true
	
func set_stack_label_position(position):
	stack_label_position = position
	_update_stack_label()
	
func set_stack_label_show(value):
	stack_label_show = value
	_update_stack_label()