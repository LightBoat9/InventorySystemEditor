# This slot adds drag and drop functionality.
extends "res://addons/inventory/custom_nodes/slot.gd"

signal drag_started
signal drag_ended

enum DragOrigin {
	CENTER, RELATIVE, CUSTOM
}

# warning-ignore:unused_class_variable
export var next_groups: PoolStringArray = PoolStringArray()

export var drag_disabled: bool = false
export var drag_toggle: bool = true
export(DragOrigin) var drag_origin = DragOrigin.CENTER
export var custom_drag_origin: Vector2 = Vector2()

# This will repeat the quick move function until either
# the item cannot be moved or the item is fully moved
export var repeat_group_move: bool = true

var _is_dragging: bool = false setget _set_is_dragging
var _relative_pos: Vector2 = Vector2()
var _drag_texture_rect: TextureRect = TextureRect.new()

var _drag_item: Item = null setget set_drag_item
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if not event.is_echo():
			if item != null:
				if event.button_index == BUTTON_LEFT and event.pressed:
					if event.shift and next_groups.size() > 0:
						var next_slot = _find_valid_slot(item, next_groups)
						# Continue as long as slots are valid
						while next_slot:
							move_item_to_slot(next_slot)
							# If set to not repeat only loop once
							if not repeat_group_move:
								break
							# If the item is fully moved we're done
							if not item:
								break
							# Grab the next slot
							next_slot = _find_valid_slot(item, next_groups)
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
						self._drag_item = item.split_duplicate()
						self._drag_item.stack = int(item.stack / 2)
						self.item.stack -= _drag_item.stack
						self._is_dragging = true
				
func _input(event: InputEvent) -> void:
	if _is_dragging:
		if event is InputEventMouseButton:
			if not event.is_echo():
				if event.pressed:
					if event.button_index == BUTTON_LEFT:
						_drop()
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
				_drag_item.rect_position = get_global_mouse_position() - custom_drag_origin
			DragOrigin.CENTER:                                                    
				_drag_item.rect_position = get_global_mouse_position() - _drag_item.rect_size / 2
			DragOrigin.RELATIVE:
				_drag_item.rect_position = get_global_mouse_position() - _relative_pos
				
func _set_is_dragging(to: bool) -> void:
	_is_dragging = to
	
	if _is_dragging:
		_relative_pos = _drag_item.get_local_mouse_position()
		emit_signal("drag_started")
	else:
		queue_sort()
		emit_signal("drag_ended")
		
func _drop():
	if not _drag_item:
		return
		
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			move_dragging_item_to_slot(slot)
			return
		
	# If it gets this far then no slots were clicked and item must return
	if _drag_item:
		if item == null:
			self.item = _drag_item
			self._drag_item = null
			self._is_dragging = false
		elif item.item_name == _drag_item.item_name:
			if _drag_item.stack + item.stack <= item.max_stack:
				self.item.stack += _drag_item.stack
				self._drag_item.queue_free()
				self._drag_item = null
				self._is_dragging = false
			else:
				var diff: int = item.max_stack - item.stack
				self.item.stack += diff
				self._drag_item.stack -= diff
		# Otherwise cannot return because item and _drag_item
		# are different types
		
func _drop_single() -> void:
	if not _drag_item:
		return
		
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if slot.confine_categories.size() == 0 or _drag_item.has_category_overlap(slot.confine_categories):
				if slot.item:
					if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
						if _drag_item.item_name == slot.item.item_name:
							if slot.item.stack + 1 < slot.item.max_stack:
								slot.item.stack += 1
								_drag_item.stack -= 1
								if _drag_item.stack <= 0:
									_drag_item.queue_free()
									_drag_item = null
									self._is_dragging = false
								break
				else:
					var inst = _drag_item.split_duplicate()
					inst.stack = 1
					slot.item = inst
					
					self._drag_item.stack -= 1
					if _drag_item.stack <= 0:
						_drag_item.queue_free()
						_drag_item = null
						self._is_dragging = false
					break
						
func _find_valid_slot(for_item: Item, groups:PoolStringArray) -> PanelContainer:
	if groups.size() > 0:
		for gr in groups:
			for slot in get_tree().get_nodes_in_group(gr):
				if slot.confine_categories.size() == 0 or item.has_category_overlap(slot.confine_categories):
					if not slot.item or (slot.item.item_name == for_item.item_name and not slot.item.is_full()):
						return slot
	
	return null
	
func set_drag_item(to: Item) -> void:
	if _drag_item:
		_drag_item.set_as_toplevel(false)
		
	_drag_item = to
	
	if _drag_item and _drag_item.is_inside_tree():
		_drag_item.get_parent().remove_child(_drag_item)
	
	if _drag_item:
		add_child(_drag_item)
		_drag_item.set_as_toplevel(true)
		
func move_item_to_slot(slot) -> void:
	""" Move this slot's item to the other slot. 
	
		If the other slot already contains an item they will.
			a) Merge together if they are the same item
			b) Swap places if they are different
		
		Otherwise the item will be moved to the other slot
	"""
	# Assume that since this item is in this slot it matches the category
	# If the slot to move to has an item
	if slot.item:
#		TODO: Add back item swapping and fix infinite loop from shift clicking
#		# Both slots must support the items that will swap
#		if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
		# If the full item stack can be added
		if item.stack + slot.item.stack < slot.item.max_stack:
			item.queue_free()
			slot.item.stack += item.stack
			self.item = null
		# Otherwise either the stack is full or only partial can be added
		else:
			# Add partial
			if slot.item.stack != slot.item.max_stack:
				var diff: int = slot.item.max_stack - slot.item.stack
				slot.item.stack += diff
				self.item.stack -= diff
	else:
		slot.item = item
		self.item = null
		
func move_dragging_item_to_slot(slot) -> void:
	if slot.confine_categories.size() == 0 or _drag_item.has_category_overlap(slot.confine_categories):
		# If the other slot also has item they must swap
		if slot.item:
			# Both slots must support the items that will swap
			if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
				# If moving to a slot with the same item
				if _drag_item.item_name == slot.item.item_name:
					# If the full drag item stack can be added
					if _drag_item.stack + slot.item.stack <= slot.item.max_stack:
						_drag_item.queue_free()
						slot.item.stack += _drag_item.stack
						self._is_dragging = false
						self._drag_item = null
					# Otherwise either the stack is full or only partial can be added
					else:
						# If it is full
						if slot.item.stack == slot.item.max_stack:
							var temp = slot.item
							slot.item = _drag_item
							slot._drag_item = temp
							slot._is_dragging = true
							# If swapping with self don't stop drag
							if slot != self:
								self._drag_item = null
								self._is_dragging = false
						# Add partial
						else:
							var diff: int = slot.item.max_stack - slot.item.stack
							slot.item.stack += diff
							self._drag_item.stack -= diff
				# If moving to a slot with a different item
				else:
					# If no item in this slot just swap
					if item == null:
						var temp = slot.item
						slot.item = _drag_item
						self._drag_item = temp
						self._is_dragging = true
					else:
						var temp = slot.item
						slot.item = _drag_item
						slot._drag_item = temp
						slot._is_dragging = true
						# If swapping with self don't stop drag
						if slot != self:
							self._drag_item = null
							self._is_dragging = false
				
		# Otherwise if the slot is empty just move the item
		else:
			slot.item = _drag_item
			self._is_dragging = false
			_drag_item = null
