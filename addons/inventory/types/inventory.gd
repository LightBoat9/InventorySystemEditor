tool
extends Sprite

## Signals
# Sent when an inventory_item is changed in some way
signal item_added
signal item_moved
signal item_removed
signal item_dropped
signal item_stack_changed
# Signals from the slots
signal slot_mouse_over
# Sent at the start / stop of dragging the inventory if dragging is enabled
signal drag_start
signal drag_stop

## Objects
var InventorySlot = load("res://addons/inventory/types/inventory_slot.gd")

## Exports
# Slots
export(Vector2) var slots = Vector2(2,2) setget set_slots
export(Texture) var slots_texture = load("res://addons/inventory/assets/slot.png") setget set_slots_texture
export(Vector2) var slots_spacing = Vector2(32, 32) setget set_slots_spacing
export(Vector2) var slots_offset = Vector2(0, 0) setget set_slots_offset
export(bool) var slots_centered = false setget set_slots_centered
export(bool) var slots_modulate = true setget set_slots_modulate
export(Color) var slots_modulate_color = Color(230.0/255.0,230.0/255.0,230.0/255.0,1) setget set_slots_modulate_color
# Drag
export(bool) var draggable = true setget set_draggable
export(bool) var drag_rect_show = true setget set_drag_rect_show
export(Rect2) var drag_rect = Rect2(Vector2(0,-32), Vector2(64,32)) setget set_drag_rect
export(Color) var drag_rect_color = Color(1,1,1) setget set_drag_rect_color

## Self Variables
# Slots
var arr_slots = []
var _temp_items = [] # Temporary item storage for when editing the inventory
# Items
var arr_items = []
var arr_items_dropped = [] # Contains any items that were forced out of the inventory
# Mouse
var mouse_over = false
var _mouse_relative = Vector2()
# Drag
var drag_region
var dragging = false

## Built In Methods
func _enter_tree():
	_remove_slots()
	_add_slots()
	update()
	_update_slots()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = _mouse_in_rect(event.global_position, global_position + drag_rect.position, drag_rect.size, scale)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if draggable:
				if mouse_over:
					dragging = event.pressed
					_mouse_relative = position - get_global_mouse_position()
					emit_signal("drag_start")
				else:
					dragging = false
				if dragging:
					var ItemType = load("res://addons/inventory/types/inventory_item.gd")
					for inst in get_tree().get_nodes_in_group("inventory_dragabbles"):
						if inst.dragging and inst is ItemType:
							dragging = false
							break
						if inst != self:
							inst.dragging = false
				else:
					emit_signal("drag_stop")
			
func _physics_process(delta):
	if dragging:
		position = get_global_mouse_position() + _mouse_relative
	
func _draw():
	if drag_rect_show:
		draw_rect(drag_rect, drag_rect_color)
	
## Private Methods
func _add_slots():
	for y in range(slots.y):
		for x in range(slots.x):
			var inst = InventorySlot.new()
			inst.global_position = Vector2(offset.x + x * slots_spacing.x,offset.y + y * slots_spacing.y)
			inst.connect("item_added", self, "_item_added")
			inst.connect("item_removed", self, "_item_removed")
			inst.connect("item_stack_changed", self, "_item_stack_changed")
			inst.connect("mouse_over", self, "_slot_mouse_over")
			inst.texture = slots_texture
			add_child(inst)
			arr_slots.append(inst)
	_add_removed_items()
			
func _remove_slots():
	_temp_items = arr_items.duplicate()
	arr_items.clear()
	while arr_slots.size():
		var inst = arr_slots.pop_back()
		if inst.item:
			inst.item.slot = null
			if inst.item.get_parent():
				inst.item.get_parent().remove_child(inst.item)
		if inst.get_parent():
			inst.get_parent().remove_child(inst)
		
func _update_slots():
	for y in range(slots.y):
		for x in range(slots.x):
			var slot = arr_slots[x+(y*slots.x)]
			slot.position = Vector2(slots_offset.x + x * slots_spacing.x, slots_offset.y + y * slots_spacing.y)
			slot.texture = slots_texture
			slot.hover_modulate = slots_modulate
			slot.modulate_color = slots_modulate_color
			slot.centered = slots_centered
			
func _item_added(item):
	if not arr_items.has(item):
		arr_items.append(item)
		emit_signal("item_added", item)
	else:
		emit_signal("item_moved", item)
	
func _item_removed(item):
	arr_items.erase(item)
	emit_signal("item_removed", item)
	
func _item_stack_changed(item):
	# Remove deleted items
	for i in arr_items:
		if i == item and item.stack == 0:
			arr_items.remove(arr_items.find(item))
	emit_signal("item_stack_changed", item)
	
func _add_removed_items():
	for slot in arr_slots:
		if len(_temp_items):
			var inst = _temp_items.pop_front()
			slot.set_item(inst)
		else:
			break
	for item in _temp_items:
		arr_items_dropped.append(item)
		emit_signal("item_dropped", item)
	_temp_items.clear()
	
func _slot_mouse_over(inst):
	emit_signal("slot_mouse_over", inst)
	
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1)):
	return (
		mouse_pos.x >= rect_pos.x and 
		mouse_pos.x <= rect_pos.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y and 
		mouse_pos.y <= rect_pos.y + size.y * scale.y
		)
	
## Public Methods
func add_item(item):
	for y in range(slots.y):
		for x in range(slots.x):
			var slot = arr_slots[x+(y*slots.x)]
			if slot.item and slot.item.id == item.id:
				var overflow = slot.item.set_stack(slot.item.stack + item.stack)
				item.set_stack(overflow)
				if overflow == 0:
					return
			if not slot.item:
				slot.set_item(item)
				return
	arr_items_dropped.append(item)
	emit_signal("item_dropped", item)
			
func set_slots(value):
	_remove_slots()
	slots = value
	_add_slots()
	_update_slots()
			
func set_slots_texture(value):
	slots_texture = value
	_update_slots()
	
func set_slots_centered(value):
	slots_centered = value
	_update_slots()
	
func set_slots_offset(value):
	slots_offset = value
	_update_slots()
	
func set_slots_spacing(value):
	slots_spacing = value
	_update_slots()
	
func set_slots_modulate(value):
	slots_modulate = value
	_update_slots()
	
func set_slots_modulate_color(value):
	slots_modulate_color = value
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
	if draggable:
		add_to_group("inventory_dragabbles")
	elif is_in_group("inventory_dragabbles"):
		remove_from_group("inventory_dragabbles")