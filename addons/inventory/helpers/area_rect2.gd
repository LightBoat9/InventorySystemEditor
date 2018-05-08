tool
extends TextureRect

signal mouse_over_input
signal rect_mouse_entered
signal rect_mouse_exited

var rect = Rect2(Vector2(), Vector2())

var color = Color(1,1,1)
var filled = false

export(bool) var debug_in_game = true setget set_debug_in_game
export(bool) var debug_in_editor = true setget set_debug_in_editor
var mouse_over = false

func _enter_tree():
	add_to_group("area_rects")
	
func _ready():
	connect("mouse_entered", self, "__mouse_entered")
	connect("mouse_exited", self, "__mouse_exited")

func _draw():
	if (debug_in_editor and Engine.editor_hint) or debug_in_game:
		draw_rect(rect, color, filled)

func _input(event):
	if mouse_over:
		emit_signal("mouse_over_input", event)
		
func __mouse_entered():
	mouse_over = true
	
func __mouse_exited():
	mouse_over = false
			
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
			
func set_debug_in_game(value):
	debug_in_game = value
	update()
	
func set_debug_in_editor(value):
	debug_in_editor = value
	update()