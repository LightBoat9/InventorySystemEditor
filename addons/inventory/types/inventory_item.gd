tool
extends TextureRect

signal drag_start
signal drag_stop

# Property Exports
export var id = 0
# Drag Exports
export(bool) var draggable = true
export(bool) var return_if_dragged = true
export(bool) var drag_on_remove = true
export(bool) var overlap_on_drag = true
# Stack Exports
export(bool) var stackable = true
export(bool) var stack_label_show = true setget set_stack_label_show
export(int) var stack = 1 setget set_stack
export(Vector2) var stack_label_position = Vector2(64, 64) setget set_stack_label_position
export(int) var max_stack = 99

onready var world_parent = get_node("/root").get_child(get_node("/root").get_child_count() - 1)
var mouse_over = false
var dragging = false
var drag_start_position = Vector2()

var slot = null
var return_slot = null

var stack_label = Label.new()
	
func _enter_tree():
	_update_stack_label()
	if not stack_label.get_parent():
		add_child(stack_label)
	add_to_group("inventory_items")
	
func _ready():
	add_to_group("inventory_dragabbles")
	set_process_input(true)
	set_physics_process(true)
		
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = _mouse_in_rect(event.global_position, rect_global_position, rect_size, rect_scale)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if draggable:
			if dragging and not event.pressed:
				_drop()
			dragging = mouse_over and event.pressed
			if dragging:
				drag_init()
			else:
				emit_signal("drag_stop")
	
func _physics_process(delta):
	if dragging and draggable:
		rect_global_position = get_global_mouse_position() - (rect_size * rect_scale) / 2
		
func _drop():
	for inst in get_tree().get_nodes_in_group("inventory_slots"):
		if inst.mouse_over:
			# Drop self or stack with other item
			if inst.item and inst.item.id == id:
				var overflow = inst.item.set_stack(inst.item.stack + stack)
				set_stack(overflow)
				if return_slot and not return_slot.item and overflow:
					return_slot.set_item(self)
				return_slot = null
				break
			# Add self to slot
			elif not inst.item:
				slot = inst
				slot.set_item(self)
				return_slot = null
				break
	for inst in get_tree().get_nodes_in_group("inventory_items"):
		if inst != self and inst.mouse_over and inst.id == id:
			set_stack(inst.set_stack(inst.stack + stack))
			rect_global_position = drag_start_position
			break
	if return_slot and not return_slot.item:
		return_slot.set_item(self)
		return_slot = null
	
func _update_stack_label():
	if stack_label_show:
		stack_label.show()
	else:
		stack_label.hide()
	stack_label.text = str(stack)
	stack_label.rect_position = stack_label_position
	
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1)):
	return (
		mouse_pos.x >= rect_pos.x and 
		mouse_pos.x <= rect_pos.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y and 
		mouse_pos.y <= rect_pos.y + size.y * scale.y
		)
	
func set_stack(amount):
	var overflow = 0
	stack = amount
	if stack > max_stack:
		overflow = stack - max_stack
		stack = max_stack
	if stack <= 0:
		queue_free()
	_update_stack_label()
	return overflow
			
func remove_from_slot():
	"""Adds the item back into the world"""
	if not get_parent():
		world_parent.add_child(self)
	
	dragging = drag_on_remove
		
	if return_if_dragged:
		return_slot = slot
	slot = null
	
func drag_init():
	drag_start_position = rect_global_position
	var parent = get_parent()
	parent.remove_child(self)
	parent.add_child(self)
	for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
		if inst != self:
			inst.dragging = false
	emit_signal("drag_start")
				
func set_stack_label_position(position):
	stack_label_position = position
	_update_stack_label()
	
func set_stack_label_show(value):
	stack_label_show = value
	_update_stack_label()