tool
extends Container

enum DragOrigin {
	CENTER, RELATIVE, TOPLEFT
}

export(DragOrigin) var drag_origin = DragOrigin.RELATIVE
export var custom_drag_origin: Vector2 = Vector2()

export var slot_box: StyleBox setget set_slot_box
export var grid_size: Vector2 = Vector2(3, 3) setget set_grid_size
export var slot_size: Vector2 = Vector2(64, 64) setget set_slot_size

export var block_doubleclick: bool = false

var map: Array = []

var items: Dictionary = {}
var drag_item: SpaceItem setget set_drag_item

var _relative_pos: Vector2 = Vector2()

func _draw():
	if slot_box:
		for y in range(grid_size.y):
			for x in range(grid_size.x):
				draw_style_box(slot_box, Rect2(Vector2(x, y) * slot_size, slot_size))
				
				if get_item_at(Vector2(x, y)):
					draw_rect(Rect2(Vector2(x, y) * slot_size, slot_size), Color(0, 0, 1, 0.25))
				
		rect_size = grid_size * slot_size
		
	if drag_item:
		var hover_pos = get_hovered_slot()
		if get_overlap_items(hover_pos, drag_item.span).empty():
			draw_rect(Rect2(hover_pos * slot_size, slot_size * drag_item.span), Color(0, 1, 0, 0.25))
		else:
			draw_rect(Rect2(hover_pos * slot_size, slot_size * drag_item.span), Color(1, 0, 0, 0.25))
		
func slot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (not event.doubleclick or not block_doubleclick):
		if not drag_item:
			if event.button_index == BUTTON_LEFT and event.pressed:
				var item = get_item_at((event.position / slot_size).floor())
				if item:
					self.drag_item = item
			elif event.button_index == BUTTON_RIGHT and event.pressed:
				split_and_drag(get_item_at((event.position / slot_size).floor()))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (not event.doubleclick or not block_doubleclick):
		if drag_item:
			if event.button_index == BUTTON_LEFT and event.pressed:
				var item = get_item_at((get_local_mouse_position() / slot_size).floor())
				_drop(item)
				get_tree().set_input_as_handled()
			elif event.button_index == BUTTON_RIGHT and event.pressed:
				var item = get_item_at((get_local_mouse_position() / slot_size).floor())
				_drop_single(item)
				get_tree().set_input_as_handled()
					
func _grab_relative_position(of: SpaceItem):
	var local_rect = Rect2(Vector2(), of.rect_size)
	
	if local_rect.has_point(of.get_local_mouse_position()):
		_relative_pos = get_global_mouse_position() - of.rect_global_position#of.get_local_mouse_position()
	else:
		var mouse = of.get_local_mouse_position()
		_relative_pos = Vector2(clamp(mouse.x, 0, of.rect_size.x), clamp(mouse.y, 0, of.rect_size.y))
					
func _drop(item) -> void:
	if item:
		if item.item_name == drag_item.item_name and not item.is_full():
			if drag_item.stack + item.stack <= item.max_stack:
				drag_item.queue_free()
				item.stack += drag_item.stack
				self.drag_item = null
			else:
				var diff: int = item.max_stack - item.stack
				item.stack += diff
				drag_item.stack -= diff
		else:
			var drop_pos = get_hovered_slot()
			var overlaps = get_overlap_items(drop_pos, drag_item.span)
			
			if overlaps.empty():
				add_item(drag_item, drop_pos)
			elif overlaps.size() == 1:
				var temp = drag_item
				self.drag_item = overlaps[0]
				add_item(temp, drop_pos)
	else:
		var drop_pos = get_hovered_slot()
		var overlaps = get_overlap_items(drop_pos, drag_item.span)
		
		if overlaps.empty():
			add_item(drag_item, drop_pos)
		elif overlaps.size() == 1:
			var temp = drag_item
			self.drag_item = overlaps[0]
			add_item(temp, drop_pos)
			
func _drop_single(item) -> void:
	if item:
		if item.item_name == drag_item.item_name:
			if not item.is_full():
				item.stack += 1
				drag_item.stack -= 1
				
				if drag_item.stack <= 0:
					drag_item.queue_free()
					self.drag_item = null
	else:
		var drop_pos = get_hovered_slot()
		
		if get_overlap_items(drop_pos, drag_item.span).empty():
			if drag_item.stack <= 1:
				add_item(drag_item, drop_pos)
			else:
				var split = drag_item.split_duplicate()
				split.stack = 1
				drag_item.stack -= 1
				add_item(split, drop_pos)
		
func _enter_tree():
	_create_map()
	connect("gui_input", self, "slot_gui_input")
	
func _exit_tree():
	disconnect("gui_input", self, "slot_gui_input")
	
func _process(delta: float) -> void:
	if drag_item:
		match drag_origin:
			DragOrigin.TOPLEFT:
				drag_item.rect_global_position = get_global_mouse_position() - custom_drag_origin + custom_drag_origin
			DragOrigin.CENTER:                                                    
				drag_item.rect_global_position = get_global_mouse_position() - drag_item.rect_size / 2 + custom_drag_origin
			DragOrigin.RELATIVE:
				drag_item.rect_global_position = get_global_mouse_position() - _relative_pos + custom_drag_origin
				
	update()

func _create_map() -> void:
	map.clear()
	for y in grid_size.y:
		map.append([])
		for x in grid_size.x:
			map[y].append(null)
			
func get_item_at(pos: Vector2) -> SpaceItem:
	if map.empty() or pos.x < 0 or pos.y < 0 or pos.x >= grid_size.x or pos.y >= grid_size.y:
		return null
	
	return map[pos.y][pos.x]

func set_slot_box(to: StyleBox) -> void:
	# Remove previous box's changed signal
	if slot_box:
		slot_box.disconnect("changed", self, "update")
	
	slot_box = to
	slot_box.connect("changed", self, "update")
	
func set_grid_size(to: Vector2) -> void:
	grid_size = to.floor()
	_create_map()

func set_slot_size(to: Vector2) -> void:
	slot_size = to
	
func add_item(item: SpaceItem, pos: Vector2):
	if item and item.is_inside_tree():
		item.get_parent().remove_child(item)
		
	if item == drag_item:
		item.set_as_toplevel(false)
		self.drag_item = null
		
	add_child(item)
	
	items[item] = pos
	
	for y in range(pos.y, pos.y + item.span.y):
		for x in range(pos.x, pos.x + item.span.x):
			map[y][x] = item
	
	item.rect_min_size = item.span * slot_size
	item.rect_position = pos * slot_size
	queue_sort()
	
func remove_item(item: SpaceItem):
	for y in range(items[item].y, items[item].y + item.span.y):
		for x in range(items[item].x, items[item].x + item.span.x):
			map[y][x] = null
			
	items.erase(item)
	
func set_drag_item(to: SpaceItem) -> void:
	if to and items.has(to):
		remove_item(to)
		
	if to and to.is_inside_tree() and to.get_parent() != self:
		to.get_parent().remove_child(to)
		
	if drag_item:
		drag_item.set_as_toplevel(false)
		queue_sort()
		
	drag_item = to
	
	if drag_item and drag_item.is_inside_tree():
		_grab_relative_position(drag_item)
	
	if drag_item and not drag_item.is_inside_tree():
		add_child(drag_item)
		
	if drag_item:
		drag_item.set_as_toplevel(true)
		
func get_hovered_slot() -> Vector2:
	var loc = get_local_mouse_position()
	if drag_item:
		match drag_origin:
			DragOrigin.TOPLEFT:
				loc -= custom_drag_origin + custom_drag_origin
			DragOrigin.CENTER:                                                    
				loc -= drag_item.rect_size / 2 + custom_drag_origin
			DragOrigin.RELATIVE:
				loc -= _relative_pos + custom_drag_origin
		
	var min_size = Vector2(0, 0)
	var max_size = (
		Vector2(slot_size.x * grid_size.x, slot_size.y * grid_size.y) - 
		Vector2(
			slot_size.x * drag_item.span.x, 
			slot_size.y * drag_item.span.y))
	
	var loc_clamp = Vector2(clamp(loc.x, min_size.x, max_size.x), clamp(loc.y, min_size.y, max_size.y))
	return (loc_clamp / slot_size).round()
	
func get_overlap_items(pos: Vector2, span: Vector2) -> Array:
	var items = []
	
	for y in range(pos.y, pos.y + span.y):
		for x in range(pos.x, pos.x + span.x):
			if map[y][x] != null and not map[y][x] in items:
				items.append(map[y][x])
				
	return items

func split_and_drag(item: SpaceItem) -> void:
	if item:
		if item.stack == 1:
			self.drag_item = item
		else:
			_grab_relative_position(item)
			self.drag_item = item.split_duplicate()
			drag_item.stack = int(item.stack / 2)
			item.stack -= drag_item.stack
