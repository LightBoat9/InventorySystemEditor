"""
	* Caution * 
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Sprite and adding a script with the following code.
	
tool
extends "res://addons/inventory/types/inventory_item.gd"
		
"""
tool
extends TextureRect
	
signal drag_started
signal drag_stopped
signal drop_outside_slot
signal stack_changed
signal global_mouse_entered
signal global_mouse_exited
	
export(bool) var debug_in_game = false setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
# Properties
export var id = 0
# Drag
export(bool) var draggable = true setget set_draggable
export(int, "Relative", "Center", "Position") var drag_mode = 0
export(Vector2) var drag_position = Vector2()
export(bool) var hold_to_drag = false setget set_hold_to_drag
export(int) var dead_zone_radius = 0
# Stack
export(bool) var stackable = true
export(int) var stack = 1 setget set_stack
export(int) var max_stack = 99 setget set_max_stack
export(bool) var remove_if_empty = true
	
var dragging = false setget set_dragging
var slot = null
var _mouse_relative = Vector2()  # Relative position of mouse for dragging relative
var _dead_zone_drag = false
var _dead_zone_center = Vector2()

var mouse_over = false

const RECT_COLOR = Color("22A7F0")
const RECT_FILLED = false
	
func _ready():
	add_to_group("inventory_nodes")
	add_to_group("inventory_items")
	connect("global_mouse_entered", self, "__mouse_entered")
	connect("global_mouse_exited", self, "__mouse_exited")
	
func _input(event):
	if event is InputEventMouseMotion:
		var last_mouse_over = mouse_over
		mouse_over = _mouse_in_rect(event.position, rect_position * rect_scale, rect_size * rect_scale)
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
					set_dragging(false)
					get_tree().set_input_as_handled()
			elif draggable and event.pressed and mouse_over and is_top() and not current_dragging():
				if not hold_to_drag or dead_zone_radius == 0 or _dead_zone_drag:
					set_dragging(true)
					get_tree().set_input_as_handled()
				else:
					_dead_zone_drag = true
					_dead_zone_center = get_local_mouse_position()
					update()
			if _dead_zone_drag and not event.pressed:
				_dead_zone_drag = false
				update()
				
func _mouse_in_rect(mouse_pos, rect_pos, rect_size):
	return (mouse_pos.x >= rect_pos.x and mouse_pos.x <= rect_pos.x + rect_size.x and
			mouse_pos.y >= rect_pos.y and mouse_pos.y <= rect_pos.y + rect_size.y)
		
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
		if _dead_zone_drag and dead_zone_radius > 0:
	    	draw_circle_arc(_dead_zone_center, dead_zone_radius, 0, 360, RECT_COLOR)
	
func __mouse_entered():
	mouse_over = true
	
func __mouse_exited():
	mouse_over = false
	
func __drag_started(x):
	dragging = true
	make_top()
	emit_signal("drag_started", self)
	
func __drag_stopped(x):
	dragging = false
	__drop()
	
func __drop():
	var top = top_node()
	if top:
		print(top)
		if top.is_in_group("inventory_slots"):
			if top.item and top.item != self:
				if top.item.id == self.id:
					set_stack(top.item.add_stack(stack))
				elif self.slot:
					__drop_swap(top)
			else:
				top.set_item(self)
		elif top.is_in_group("inventory_items"):
			if top.id == self.id:
				set_stack(top.add_stack(stack))
			elif top.slot and top != self and self.slot:
				__drop_swap(top.slot)
				
	if slot:
		if not top or not top.is_in_group("inventory_slots"):
			emit_signal("drop_outside_slot", self)
		#rect_position = rect_position * rect_scale + slot.rect_position * slot.rect_scale
		rect_global_position = slot.rect_global_position
	emit_signal("drag_stopped", self)
	
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
		slot.remove_item()
	.free()
	
func queue_free():
	"""Overides Node.queue_free to ensure references to the item are removed"""
	if slot:
		slot.remove_item()
	.queue_free()
	
func remove_from_tree():
	if slot:
		slot.remove_item()
	if get_parent():
		get_parent().remove_child(self)
		
func set_draggable(value):
	draggable = value
	
func set_hold_to_drag(value):
	hold_to_drag = value
	
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
	if stack <= 0 and remove_if_empty:
		queue_free()
	emit_signal("stack_changed", self)
	return overflow
	
func set_max_stack(value):
	max_stack = value
	if stack > max_stack:
		set_stack(max_stack)
	
func set_dragging(value):
	dragging = value
	if dragging:
		_mouse_relative = get_local_mouse_position() * rect_scale
		emit_signal("drag_started", self)
		make_top()
	else:
		__drop()
		emit_signal("drag_stopped", self)
	
func set_debug_in_game(value):
	debug_in_game = value
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	update()
	
func items_no_slot():
	var items = get_tree().get_nodes_in_group("inventory_items")
	var arr = []
	for item in items:
		if not item.slot:
			arr.append(item)
	return arr
		
	
func make_top():
	"""Orders all inventory_nodes by their z_index and makes self the top z_index"""
	var all_nodes = get_tree().get_nodes_in_group("inventory_nodes")
	var nodes = []
	for inst in all_nodes:
		if inst != self:
			var index = len(nodes)-1
			while not inst in nodes:
				if not len(nodes):
					nodes.append(inst)
				elif not inst.is_greater_than(nodes[index]):
					nodes.insert(index, inst)
				elif inst.is_greater_than(nodes[index]):
					nodes.insert(index+1, inst)
				index += 1
	nodes.append(self)
	for i in len(nodes):
		nodes[i].raise()
		
func is_top():
	var nodes = get_tree().get_nodes_in_group("inventory_nodes")
	for node in nodes:
		if node.mouse_over and node.is_greater_than(self):
			return false
	return true
	
func current_dragging():
	var nodes = get_tree().get_nodes_in_group("inventory_nodes")
	for node in nodes:
		if node.dragging:
			return node
	
func top_node(group="inventory_nodes", mouse_over=true, not_self=true):
	"""Return the top (highest z_index) node in the group (default "inventory_nodes").
	
		(bool) mouse_over : only check items with mouse_over.
		(bool) not_self : only check items that are not self.
	"""
	var top = null
	for node in get_tree().get_nodes_in_group(group):
		if (node.mouse_over or not mouse_over) and (node != self or not not_self):
			if not top:
				top = node
			elif node.is_greater_than(top):
				top = node
	return top
	
func dragging_update():
	if dragging:
		match drag_mode:
			0:
				rect_global_position = get_global_mouse_position() - _mouse_relative
			1:
				rect_global_position = get_global_mouse_position() - (rect_size * rect_scale / 2.0)
			2:
				rect_global_position = get_global_mouse_position() - drag_position