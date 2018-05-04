tool
extends Node2D

signal mouse_entered
signal mouse_exited
signal mouse_over_input

var rect = Rect2(Vector2(), Vector2())

var color = Color(1,1,1)
var filled = false

var debug_mode = true
var mouse_over = false

func _enter_tree():
	add_to_group("area_rects")

func _draw():
	if Engine.editor_hint or debug_mode:
		draw_rect(rect, color, filled)

func _input(event):
	if mouse_over:
		emit_signal("mouse_over_input", event)
	if event is InputEventMouseMotion:
		var last_mouse_over = mouse_over
		mouse_over = _mouse_in_rect(event.position, global_position + rect.position * get_parent().scale, rect.size * get_parent().scale)
		if not last_mouse_over and mouse_over:
			emit_signal("mouse_entered", self)
		elif last_mouse_over and not mouse_over:
			emit_signal("mouse_exited", self)
			
func is_top(group="area_rects"):
	for inst in get_tree().get_nodes_in_group(group):
		if inst.mouse_over and inst.global_z_index() > global_z_index():
			return false
	return true
	
func global_z_index():
	var node = self
	var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	var total = 0
	while node != main:
		total += node.z_index
		node = node.get_parent()
	return total

func _mouse_in_rect(mouse_pos, rect_pos, rect_size):
	return (mouse_pos.x >= rect_pos.x and mouse_pos.x <= rect_pos.x + rect_size.x and
			mouse_pos.y >= rect_pos.y and mouse_pos.y <= rect_pos.y + rect_size.y)