# This slot adds drag and drop functionality.
extends "res://addons/inventory/custom_nodes/slot.gd"

signal drag_started
signal drag_ended

enum DragOrigin {
	CENTER, RELATIVE, CUSTOM
}

export var next_group: String = ""

export var drag_disabled: bool = false
export var drag_toggle: bool = true
export(DragOrigin) var drag_origin = DragOrigin.CENTER
export var custom_drag_origin: Vector2 = Vector2()

var _is_dragging: bool = false setget _set_is_dragging
var _relative_pos: Vector2 = Vector2()
var _drag_texture_rect: TextureRect = TextureRect.new()

var _is_dragging_partial: bool = false setget _set_is_dragging_partial
var _drag_item: Item = null setget set_drag_item

func _enter_tree():
	get_drag_texture_rect().expand = true
	get_drag_texture_rect().set_as_toplevel(true)
	_match_rect_sizes()
	get_texture_rect().connect("item_rect_changed", self, "_match_rect_sizes")
	get_drag_texture_rect().visible = false
	add_child(get_drag_texture_rect())
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.is_echo():
			if item != null:
				if event.button_index == BUTTON_LEFT and event.pressed:
					if event.shift and next_group:
						var next_slot = _find_valid_slot(item, next_group)
						if next_slot:
							if next_slot.item:
								next_slot.item.stack += item.stack
								item.queue_free()
								self.item = null
							else:
								next_slot.item = item
								self.item = null
					else:
						self._drag_item = item
						self.item = null
						self._is_dragging = true
				elif event.button_index == BUTTON_RIGHT and event.pressed:
					if self.item.stack == 1:
						self._drag_item = item
						self.item = null
						self._is_dragging = true
					else:
						self._drag_item = item.duplicate()
						self._drag_item.stack = int(item.stack / 2)
						self.item.stack -= _drag_item.stack
						self._is_dragging = true
				
func _input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseButton:
			if not event.is_echo():
				if event.pressed:
					if event.button_index == BUTTON_LEFT:
						self._is_dragging = false
						# Prevent immediate picking up of the item
						get_tree().set_input_as_handled()
					elif event.button_index == BUTTON_RIGHT:
						_drop_single()
						# Prevent immediate picking up of the item
						get_tree().set_input_as_handled()
				
func _process(delta: float) -> void:
	if _is_dragging:
		match drag_origin:
			DragOrigin.CUSTOM:
				get_drag_texture_rect().rect_position = get_global_mouse_position() - custom_drag_origin
			DragOrigin.CENTER:                                                    
				get_drag_texture_rect().rect_position = get_global_mouse_position() - get_drag_texture_rect().rect_size / 2
			DragOrigin.RELATIVE:
				get_drag_texture_rect().rect_position = get_global_mouse_position() - _relative_pos
				
func _set_is_dragging(to: bool) -> void:
	_is_dragging = to                  
	get_drag_texture_rect().visible = _is_dragging
	
	if _is_dragging:
		_relative_pos = get_texture_rect().get_local_mouse_position()
		emit_signal("drag_started")
	else:
		get_texture_rect().visible = true
		queue_sort()
		
		if _drag_item:
			_drop()
	
		emit_signal("drag_ended")
		
func _set_is_dragging_partial(to: bool) -> void:
	_is_dragging_partial = to
	get_drag_texture_rect().visible = _is_dragging_partial
	
	if _is_dragging_partial:
		_relative_pos = get_texture_rect().get_local_mouse_position()
		emit_signal("drag_started")
	else:
		emit_signal("drag_ended")
		_drop()
		queue_sort()
		
func _drop():
	if not _drag_item:
		return
	
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if slot.confine_categories.size() == 0 or _drag_item.has_category_overlap(slot.confine_categories):
				# If the other slot also has item they must swap
				if slot.item:
					# Both slots must support the items that will swap
					if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
						if _drag_item.item_name == slot.item.item_name:
							# If dragging the full stack merge the items
							if item == null:
								_drag_item.queue_free()
								slot.item.stack += _drag_item.stack
								_drag_item = null
							# Otherwise remove the amount from this item and add to other
							else:
								slot.item.stack += _drag_item.stack
								_drag_item.queue_free()
								_drag_item = null
						else:
							if item == null:
								var temp = slot.item
								slot.item = _drag_item
								self.item = temp
								_drag_item = null
							else:
								var temp = slot.item
								slot.item = _drag_item
								slot._is_dragging = true
								_drag_item = null
								slot._drag_item = temp
						return
				# Otherwise just move the item
				else:
					slot.item = _drag_item
					_drag_item = null
					return
					
	if _drag_item:
		if item == null:
			self.item = _drag_item
		else:
			self.item.stack += _drag_item.stack
			
		self._drag_item = null
		
func _drop_single() -> void:
	if not _drag_item:
		return
		
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if slot.confine_categories.size() == 0 or _drag_item.has_category_overlap(slot.confine_categories):
				if slot.item:
					if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
						if _drag_item.item_name == slot.item.item_name:
							slot.item.stack += 1
							_drag_item.stack -= 1
							if _drag_item.stack <= 0:
								_drag_item.queue_free()
								_drag_item = null
								self._is_dragging = false
				else:
					slot.item = _drag_item.duplicate()
					slot.item.stack = 1
					self._drag_item.stack -= 1
					if _drag_item.stack <= 0:
						_drag_item.queue_free()
						_drag_item = null
						self._is_dragging = false
						
func _find_valid_slot(for_item: Item, group:String="") -> PanelContainer:
	print(group)
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.slot_group == group or not group:
			if slot.confine_categories.size() == 0 or item.has_category_overlap(slot.confine_categories):
				if not slot.item or slot.item.item_name == for_item.item_name:
					return slot
	
	return null
					
func _match_rect_sizes() -> void:
	get_drag_texture_rect().rect_size = get_texture_rect().rect_size
						
func get_drag_texture_rect() -> TextureRect:
	return _drag_texture_rect
	
func set_drag_item(to: Item) -> void:
	_drag_item = to
	
	if to:
		get_drag_texture_rect().texture = to.get_item_texture()
	else:
		get_drag_texture_rect().texture = null
