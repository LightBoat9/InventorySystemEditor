"""
	* Caution *
	
	Changing this file will change the file for all custom nodes. 
	
	It is recommended to either...
	a) Edit this instance from another script.
	b) Extend this script by making a new Sprite and adding a script with the following code.
	
		tool
		extends "res://addons/inventory/types/inventory.gd"
		
"""
tool
extends "res://addons/inventory/types/inventory_base.gd"

signal item_added
signal item_moved
signal item_removed
signal item_dropped
signal item_stack_changed

signal slot_mouse_enter
signal slot_mouse_exit

signal drag_start
signal drag_stop

# Slots
export(GDScript) var custom_slot = load("res://addons/inventory/types/inventory_slot.gd") setget set_custom_slot
export(Vector2) var slots_amount = Vector2(2, 2) setget set_slots_amount
export(Vector2) var slots_spacing = Vector2(32, 32) setget set_slots_spacing
export(Vector2) var slots_offset = Vector2(0, 0) setget set_slots_offset
# Drag
export(bool) var draggable = true setget set_draggable
export(bool) var hold_to_drag = false
export(bool) var drag_rect_show = true setget set_drag_rect_show
export(Rect2) var drag_rect = Rect2(Vector2(-16,-32), Vector2(64,16)) setget set_drag_rect
export(Color) var drag_rect_color = Color(1,1,1) setget set_drag_rect_color
# Items
# Remove the item from the inventory if dragged outside of it and dropped
export(bool) var items_drop_remove = false
# Whether to ignore this Sprites texture when dragging and dropping this item from the inventory
export(bool) var items_ignore_background = false

var slots = []

var items = []
var items_dropped = [] # Contains any items that were forced out of the inventory

var _mouse_relative = Vector2()  # Relative position of mouse for dragging relative
var mouse_over_bgr = false

var drag_region
var dragging = false

var child_script_instance
var _default_z_index

func _enter_tree():
	add_to_group("inventory_nodes")
	add_to_group("inventories")
	_default_z_index = z_index
	_remove_slots()
	_add_slots()
	update()
	_update_slots()
	
func _input(event):
	if event is InputEventMouseMotion:
		mouse_over = _mouse_in_rect(event.global_position, global_position + drag_rect.position, drag_rect.size, scale)
		if texture:
			mouse_over_bgr = _mouse_in_rect(event.global_position, global_position, texture.get_size(), scale, centered)
	elif event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if draggable:
				if dragging:
					if hold_to_drag and not event.pressed or not hold_to_drag and event.pressed:
						set_dragging(false)
				elif event.pressed and mouse_over and _is_top_z():
					set_dragging(true)
			
func _physics_process(delta):
	if dragging:
		position = get_global_mouse_position() + _mouse_relative
	
func _draw():
	if drag_rect_show:
		draw_rect(drag_rect, drag_rect_color)
	
## Private Methods
func _add_slots():
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var inst = custom_slot.new()
			inst.inventory = self
			inst.position = Vector2(offset.x + x * slots_spacing.x,offset.y + y * slots_spacing.y)
			inst.connect("item_added", self, "_item_added")
			inst.connect("item_removed", self, "_item_removed")
			inst.connect("item_stack_changed", self, "_item_stack_changed")
			inst.connect("item_outside_slot", self, "_item_outside_slot")
			inst.connect("mouse_enter", self, "_slot_mouse_enter")
			inst.connect("mouse_exit", self, "_slot_mouse_exit")
			slots.append(inst)
			add_child(inst)
			
func _remove_slots():
	items.clear()
	while slots.size():
		var inst = slots.pop_back()
		if inst.item:
			inst.item.slot = null
			if inst.item.get_parent():
				inst.item.get_parent().remove_child(inst.item)
		if inst.get_parent():
			inst.get_parent().remove_child(inst)
		
func _update_slots():
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var slot = slots[x+(y*slots_amount.x)]
			slot.position = Vector2(slots_offset.x + x * slots_spacing.x, slots_offset.y + y * slots_spacing.y)
			
func _item_added(item):
	if not items.has(item):
		items.append(item)
		emit_signal("item_added", item)
	else:
		emit_signal("item_moved", item)
	
func _item_removed(item):
	items.erase(item)
	emit_signal("item_removed", item)
	
func _item_stack_changed(item):
	# Remove deleted items
	for i in items:
		if i == item and item.stack == 0:
			items.remove(items.find(item))
	emit_signal("item_stack_changed", item)
	
func _item_outside_slot(item):
	if items_drop_remove and item.slot and (not mouse_over_bgr or items_ignore_background):
		if item in items:
			items.erase(item)
		item.remove_from_tree()
		items_dropped.append(item)
		emit_signal("item_dropped", item)
	
func _slot_mouse_enter(inst):
	emit_signal("slot_mouse_enter", inst)
	
func _slot_mouse_exit(inst):
	emit_signal("slot_mouse_exit", inst)
	
	
func _mouse_in_rect(mouse_pos, rect_pos, size, scale=Vector2(1,1), is_centered=false):
	var ofs = Vector2()
	if is_centered:
		ofs = size*scale/2
	return (
		mouse_pos.x >= rect_pos.x - ofs.x and 
		mouse_pos.x <= rect_pos.x - ofs.x + size.x * scale.x and
		mouse_pos.y >= rect_pos.y - ofs.y and 
		mouse_pos.y <= rect_pos.y - ofs.y + size.y * scale.y
		)
		
func _is_top_z():
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		if inst.mouse_over and inst.z_index > z_index:
			return false
	return true
	
func _drag_start():
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		if inst != self and inst.dragging:
			if inst.z_index <= z_index:
				inst.set_dragging(false)
			else:
				set_dragging(false)
				return
	for inst in get_tree().get_nodes_in_group("inventory_nodes"):
		z_index = max(z_index, inst.z_index)
	z_index += 1
	emit_signal("drag_start")
	
## Public Methods
func add_item(item):
	for y in range(slots_amount.y):
		for x in range(slots_amount.x):
			var slot = slots[x+(y*slots_amount.x)]
			if slot.item and slot.item.id == item.id:
				var overflow = slot.item.set_stack(slot.item.stack + item.stack)
				item.set_stack(overflow)
				if overflow == 0:
					return
			if not slot.item:
				slot.set_item(item)
				return
	items_dropped.append(item)
	emit_signal("item_dropped", item)
	
func add_items_from_array(arr):
	for slot in slots:
		if len(arr):
			var inst = arr.pop_front()
			slot.set_item(inst)
		else:
			break
	for item in arr:
		items_dropped.append(item)
		emit_signal("item_dropped", item)
		
func remove_all_items():
	var temp_items = items.duplicate()
	items.clear()
	return temp_items
			
func set_custom_slot(value):
	var temp_items = items.duplicate()
	_remove_slots()
	custom_slot = value
	_add_slots()
	_update_slots()
			
func set_slots_amount(value):
	var temp_items = remove_all_items()
	_remove_slots()
	slots_amount = value
	_add_slots()
	add_items_from_array(temp_items)
	_update_slots()
	
func set_slots_offset(value):
	slots_offset = value
	_update_slots()
	
func set_slots_spacing(value):
	slots_spacing = value
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
		
func set_dragging(value):
	dragging = value
	if dragging:
		_mouse_relative = position - get_global_mouse_position()
		_drag_start()
	else:
		emit_signal("drag_stop")