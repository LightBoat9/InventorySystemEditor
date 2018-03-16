tool
extends TextureRect
	
export var id = 0
export(bool) var draggable = true
export(bool) var return_if_dragged = true
export(bool) var drag_on_remove = true
export(bool) var stackable = true
export(int) var stack = 1
export(int) var max_stack = 99

onready var initial_parent = get_parent()
var mouse_over = false
var dragging = false
var _drop_z_index = 1

var slot = null
var return_slot = null

var stack_label
	
func _enter_tree():
	# TODO : MAKE STACK LABEL EXPORTS
	if not stack_label:
		stack_label = Label.new()
		stack_label.set_text(str(stack))
		stack_label.rect_position = rect_size - Vector2(stack_label.get_line_height(), stack_label.get_line_height())
		stack_label.show_on_top = true
		add_child(stack_label)
	add_to_group("inventory_items")
	if draggable:
		add_to_group("inventory_dragabbles")
	else:
		if is_in_group("inventory_dragabbles"):
			remove_from_group("inventory_dragabbles")
	
func _ready():
	set_process_input(true)
	set_physics_process(true)
		
func _set_top_itemdragging():
	return true
		
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = (
			event.position.x >= rect_position.x and event.position.x <= rect_position.x + rect_size.x and
			event.position.y >= rect_position.y and event.position.y <= rect_position.y + rect_size.y
			)
	elif event is InputEventMouseButton and mouse_over and event.button_index == BUTTON_LEFT:
		if draggable:
			if dragging and not event.pressed:
				_drop()
			dragging = event.pressed
			if dragging:
				for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
					if inst != self:
						inst.dragging = false
						
	
func _physics_process(delta):
	if dragging and draggable:
		rect_position = get_global_mouse_position() - rect_size / 2
		
func _drop():
	for inst in get_tree().get_nodes_in_group("inventory_slots"):
		if inst.mouse_over:
			if inst.item and inst.item.id == id:
				inst.item.add_stack(stack)
				queue_free()
				return
			elif not inst.item:
				slot = inst
				slot.set_item(self)
				return
	for inst in get_tree().get_nodes_in_group("inventory_items"):
		if inst != self and inst.mouse_over and inst.id == id:
			inst.add_stack(stack)
			queue_free()
			return
	if return_slot and not return_slot.item:
		return_slot.set_item(self)
		return_slot = null
			
func remove_from_slot():
	"""Adds the item back into the world"""
	initial_parent.add_child(self)
	
	dragging = drag_on_remove
	if return_if_dragged:
		return_slot = slot
	slot = null
		
func add_stack(amount):
	stack += amount
	stack_label.set_text(str(stack))