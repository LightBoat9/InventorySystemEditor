tool
extends "res://addons/inventory/helpers/area_rect2.gd"

signal drag_started
signal drag_stopped

var draggable = true
var dragging = false setget set_dragging
var hold_to_drag = false

var _mouse_relative = Vector2()  # Relative position of mouse for dragging relative

func _enter_tree():
	add_to_group("drag_rects")

func _input(event):
	if event is InputEventMouseMotion:
		dragging_update()
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if dragging:
				if hold_to_drag and not event.pressed or not hold_to_drag and event.pressed:
					set_dragging(false)
			elif draggable and event.pressed and mouse_over and is_top() and not current_dragging():
				set_dragging(true)
				
func dragging_update():
	if dragging:
		get_parent().global_position = get_parent().get_global_mouse_position() - _mouse_relative
	
func current_dragging():
	for inst in get_tree().get_nodes_in_group("drag_rects"):
		if inst.dragging:
			return inst
	
func set_dragging(value):
	dragging = value
	if dragging:
		_mouse_relative = get_parent().get_local_mouse_position() * get_parent().scale
		emit_signal("drag_started", self)
		get_parent().make_top()
	else:
		emit_signal("drag_stopped", self)
		