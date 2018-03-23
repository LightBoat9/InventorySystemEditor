tool
extends Control

signal item_added
signal item_removed
signal drag_start
signal drag_stop

var InventorySlot = load("res://addons/inventory/types/inventory_slot.gd")

var arr_slots = []
var _temp_items = []
var arr_items = []
var arr_items_dropped = []

var mouse_over = false
var _mouse_relative = Vector2()
var drag_region
var dragging = false

export(int) var hslots = 2 setget set_hslots
export(int) var vslots = 2 setget set_vslots
export(int) var hoffset = 32 setget set_hoffset
export(int) var voffset = 32 setget set_voffset
export(bool) var draggable = true setget set_draggable
export(bool) var drag_rect_show = true setget set_drag_rect_show
export(Rect2) var drag_rect = Rect2(Vector2(0,-32), Vector2(64,32)) setget set_drag_rect
export(Color) var drag_rect_color = Color(1,1,1) setget set_drag_rect_color
export(Texture) var slot_texture = load("res://addons/inventory/assets/slot.png") setget set_slot_texture

func _enter_tree():
	_remove_slots()
	_add_slots()
	
func _ready():
	if draggable:
		add_to_group("inventory_dragabbles")
	set_process_input(true)
	set_physics_process(true)
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = (
			event.global_position.x >= rect_global_position.x + drag_rect.position.x and event.global_position.x <= rect_global_position.x + drag_rect.position.x + drag_rect.size.x and
			event.global_position.y >= rect_global_position.y + drag_rect.position.y and event.global_position.y <= rect_global_position.y + drag_rect.position.y + drag_rect.size.y
			)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if draggable:
				if mouse_over:
					dragging = event.pressed
					_mouse_relative = rect_position - get_global_mouse_position()
					emit_signal("drag_start")
				else:
					dragging = false
				if dragging:
					for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
						if inst != self:
							inst.dragging = false
				else:
					emit_signal("drag_stop")
			
func _physics_process(delta):
	if dragging:
		rect_position = get_global_mouse_position() + _mouse_relative
	
func _draw():
	if drag_rect_show:
		draw_rect(drag_rect, drag_rect_color)
	
func _add_slots():
	for y in range(hslots):
		for x in range(vslots):
			var inst = InventorySlot.new()
			inst.rect_global_position = Vector2(x * hoffset, y * voffset)
			inst.connect("item_added", self, "_item_added")
			inst.connect("item_removed", self, "_item_removed")
			inst.slot_texture = slot_texture
			add_child(inst)
			arr_slots.append(inst)
	_add_removed_items()
			
func _remove_slots():
	while len(arr_items_dropped):
		arr_items.append(arr_items_dropped.pop_front())
	_temp_items = arr_items.duplicate()
	arr_items.clear()
	while arr_slots.size():
		var inst = arr_slots.pop_back()
		if inst.get_parent():
			inst.get_parent().remove_child(inst)
		
func _update_slots():
	for y in range(hslots):
		for x in range(vslots):
			var slot = arr_slots[x+(y*vslots)]
			slot.rect_position = Vector2(x * hoffset, y * voffset)
			slot.slot_texture = slot_texture
			
func _item_added(item):
	arr_items.append(item)
	emit_signal("item_added", item)
	
func _item_removed(item):
	arr_items.erase(item)
	emit_signal("item_removed", item)
	
func _add_removed_items():
	for slot in arr_slots:
		if len(_temp_items):
			slot.set_item(_temp_items.pop_front())
		else:
			break
	for item in _temp_items:
		arr_items_dropped.append(item)
	_temp_items.clear()
			
func set_hslots(value):
	_remove_slots()
	hslots = value
	_add_slots()
	
func set_vslots(value):
	_remove_slots()
	vslots = value
	_add_slots()
	
func set_hoffset(value):
	hoffset = value
	_update_slots()
	
func set_voffset(value):
	voffset = value
	_update_slots()
	
func set_slot_texture(value):
	slot_texture = value
	_update_slots()
	
func set_drag_rect(value):
	drag_rect = value
	update()
	
func set_drag_rect_color(value):
	drag_rect_color = value
	update()
	
func set_drag_rect_show(value):
	drag_rect_show = value
	update()
	
func set_draggable(value):
	draggable = value