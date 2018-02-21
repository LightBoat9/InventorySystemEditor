tool
extends Sprite

var draggable = true

var _mouse_over = false
var _dragging = false

func _enter_tree():
	centered = false
	
func _ready():
	set_process_input(true)
	
func _is_point_inside_sprite(p):
	var a = global_position
	var b = Vector2(global_position.x + texture.get_size().x, global_position.y)
	var c = Vector2(global_position.x, global_position.y + texture.get_size().y)
	var d = Vector2(global_position.x + texture.get_size().x, global_position.y + texture.get_size().y)
	
	var a1 = abs((a.x * (b.y - p.y) + b.x * (p.y - a.y) + p.x * (a.y - b.y)) / 2.0)
	var a2 = abs((b.x * (c.y - p.y) + c.x * (p.y - b.y) + p.x * (b.y - c.y)) / 2.0)
	var a3 = abs((c.x * (d.y - p.y) + d.x * (p.y - c.y) + p.x * (c.y - d.y)) / 2.0)
	var a4 = abs((d.x * (a.y - p.y) + a.x * (p.y - d.y) + p.x * (d.y - a.y)) / 2.0)
	
	if a1 == 0 or a2 == 0 or a3 == 0 or a4 == 0:
		return true
	
	var sum = a1 + a2 + a3 + a4
	var rec_area = abs((a.x * b.y) + (b.x * c.y) + (c.x * d.y) + (d.x * a.y) - (b.x * a.y) - (c.x * b.y) - (d.x * c.y) - (a.x * d.y)) / 2.0
	var dum_area = texture.get_size().x * texture.get_size().y
	
	print(sum, " ", rec_area)
	
	if sum == rec_area:
		return true
		
	return false
	
func _input(event):
	if event is InputEventMouseMotion:
		_is_point_inside_sprite(event.global_position)