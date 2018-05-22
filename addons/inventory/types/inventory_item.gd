"""
	* Caution * 
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new TextureRect and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory_item.gd"
		
"""
tool
extends TextureRect
	
signal drag_started
signal drag_stopped
signal drop_outside_slot(drop_point)
signal stack_changed(amount)
signal global_mouse_entered
signal global_mouse_exited
	
export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Properties
export var id = 0
# Drag
export(bool) var draggable = true setget set_draggable
export(int, "Center", "Relative", "Position") var drag_mode = 0
export(Vector2) var drag_position = Vector2()
export(bool) var hold_to_drag = false setget set_hold_to_drag
export(float) var dead_zone_radius = 0.0 setget set_dead_zone_radius
# Stack
export(bool) var stackable = true
export(int) var stack = 1 setget set_stack
export(int) var max_stack = 99 setget set_max_stack
export(bool) var remove_if_empty = true
export(bool) var right_click_split = false
# Slot
export(bool) var slot_drop_return = true
export(bool) var allow_outside_slot = false
	
var _mouse_relative = Vector2()  # Relative position of mouse for dragging relative
var _dead_zone_drag = false
var _dead_zone_center = Vector2()
var InventoryController = preload("res://addons/inventory/types/inventory_controller.gd").new()
var dragging = false setget set_dragging
var slot = null
var mouse_over = false
var split_origin

const RECT_COLOR = Color("22A7F0")
const RECT_FILLED = false
	
enum DRAG_MODE {
	Center,
	Relative,
	Position,
}
	
func _ready():
	add_child(InventoryController)
	add_to_group("inventory_nodes")
	add_to_group("inventory_items")
	connect("global_mouse_entered", self, "__mouse_entered")
	connect("global_mouse_exited", self, "__mouse_exited")
	
func _input(event):
	if event is InputEventMouseMotion:
		var last_mouse_over = mouse_over
		mouse_over = Rect2(rect_global_position, get_rect().size).has_point(event.global_position)
		if not last_mouse_over and mouse_over:
			emit_signal("global_mouse_entered")
		elif last_mouse_over and not mouse_over:
			emit_signal("global_mouse_exited")
		dragging_update()
		if _dead_zone_drag:
			if (rect_global_position + _dead_zone_center).distance_to(get_global_mouse_position()) > dead_zone_radius:
				_dead_zone_drag = false
				set_dragging(true)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if dragging:
				if hold_to_drag and not event.pressed or not hold_to_drag and event.pressed:
					__handle_drop()
			elif event.pressed and is_target():
				if not hold_to_drag or dead_zone_radius == 0 or _dead_zone_drag:
					set_dragging(true)
					if is_inside_tree():
						get_tree().set_input_as_handled()
				else:
					_dead_zone_drag = true
					_dead_zone_center = get_local_mouse_position()
					update()
			if _dead_zone_drag and not event.pressed:
				_dead_zone_drag = false
				update()
		elif event.button_index == BUTTON_RIGHT:
			if dragging:
				if hold_to_drag and not event.pressed:
					__handle_drop()
			if event.pressed and right_click_split and is_target():
				if can_split():
					split_and_drag()
					
func __handle_drop():
	var top = InventoryController.get_top([self])
	if __can_drop(top):
		set_dragging(false)
		__drop(top)
	if is_inside_tree():
		get_tree().set_input_as_handled()
					
func __can_drop(top):
	return (hold_to_drag or allow_outside_slot or split_origin or (slot and slot_drop_return) or top and 
			((top.is_in_group("inventory_items") and top.id == id) or top.is_in_group("inventory_slots")))
		
func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()
	
    for i in range(nb_points+1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
	
    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color)
	
func _draw():
	if (debug_in_editor and Engine.editor_hint) or debug_in_game:
		draw_rect(Rect2(Vector2(), get_rect().size), RECT_COLOR, RECT_FILLED)
		if hold_to_drag and (_dead_zone_drag or Engine.editor_hint) and dead_zone_radius > 0:
			if Engine.editor_hint: 
				_dead_zone_center = rect_size * rect_scale / 2.0
			draw_circle_arc(_dead_zone_center, dead_zone_radius, 0, 360, RECT_COLOR)
	
func __mouse_entered():
	mouse_over = true
	
func __mouse_exited():
	mouse_over = false
	
func __drop(top):
	if top:
		if top.is_in_group("inventory_slots"):
			if not top.item:
				top.set_item(self)
		elif top.is_in_group("inventory_items"):
			if top.id == self.id and stackable and top.stackable:
				if not top.is_full():
					set_stack(top.add_stack(stack))
				else:
					top.set_stack(add_stack(top.stack))
				if not top.stack == 0 or not top.remove_if_empty:
					set_dragging(true)
					dragging_update()
			elif top.slot and top != self and self.slot:
				__drop_swap(top.slot)
			elif not hold_to_drag and top.slot:
				var temp_slot = top.slot
				var temp_item = top.slot.item
				top.slot.clear_item()
				temp_item.dragging = true
				temp_slot.set_item(self)
	if split_origin:
		if not slot and split_origin.slot and slot_drop_return and (stack != 0 or not remove_if_empty):
			set_stack(split_origin.add_stack(stack))
		split_origin = null
	if slot:
		if not top:
			emit_signal("drop_outside_slot", rect_global_position)
			if allow_outside_slot:
				slot.remove_item()
	if slot and not dragging:  # Check again because it the signal might remove the slot
		rect_global_position = slot.rect_global_position
	
func __drop_swap(slot):
	if slot.item != self and self.slot:
		var temp_item = slot.item
		slot.swap_items(self.slot)
		if not hold_to_drag:
			temp_item.set_dragging(true)
		temp_item._mouse_relative = _mouse_relative
		temp_item.dragging_update()
	
func free():
	"""Overides Object.free to ensure references to the item are removed"""
	if slot:
		slot.clear_item()
	.free()
	
func queue_free():
	"""Overides Node.queue_free to ensure references to the item are removed"""
	if slot:
		slot.clear_item()
	.queue_free()
		
func set_draggable(value):
	draggable = value
	
func set_hold_to_drag(value):
	hold_to_drag = value
	update()
	
func add_stack(value):
	"""
	Adds the value to stack. Return any overflow above 
	max_stack or null if the item is not stackable
	"""
	if not stackable:
		return
	return set_stack(stack + value)
	
func set_stack(value):
	"""
	Set the value of stack. Return any overflow above 
	max_stack or null if the item is not stackable
	"""
	if not stackable:
		return
	var overflow = 0
	stack = value
	if stack > max_stack:
		overflow = stack - max_stack
		stack = max_stack
	emit_signal("stack_changed", stack)
	if stack <= 0 and remove_if_empty:
		queue_free()
	return overflow
	
func set_max_stack(value):
	max_stack = value
	if stack > max_stack:
		set_stack(max_stack)
	
func set_dragging(value):
	dragging = value
	if dragging:
		_mouse_relative = get_local_mouse_position() * rect_scale
		emit_signal("drag_started")
		InventoryController.make_top(self)
		dragging_update()
	else:
		emit_signal("drag_stopped")
	
func set_debug_in_game(value):
	debug_in_game = value
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	update()
	
func set_dead_zone_radius(value):
	dead_zone_radius = value
	update()
	
func dragging_update():
	if dragging:
		match drag_mode:
			DRAG_MODE.Center:
				rect_global_position = get_global_mouse_position() - (rect_size * rect_scale / 2.0)
			DRAG_MODE.Relative:
				rect_global_position = get_global_mouse_position() - _mouse_relative
			DRAG_MODE.Position:
				rect_global_position = get_global_mouse_position() - drag_position

func is_full():
	return stack >= max_stack
	
func is_target():
	return draggable and mouse_over and InventoryController.is_top(self) and not InventoryController.current_dragging()
	
func can_split():
	return stack > 1
	
func split(smaller_stack=false):
	if can_split():
		var item = self.duplicate()
		get_parent().add_child(item)
		var temp = stack
		if smaller_stack:
			item.stack = stack / 2
			set_stack(temp - item.stack)
		else:
			set_stack(stack / 2)
			item.stack = temp - stack
		return item
	
func split_and_drag(smaller_stack=false):
	if can_split():
		var inst = split(smaller_stack)
		inst.dragging = true
		inst.split_origin = self
	
func remove_from_tree():
	if slot:
		slot.clear_item()
	if get_parent():
		get_parent().remove_child(self)
	