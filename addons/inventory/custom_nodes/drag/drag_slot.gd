# This slot adds drag and drop functionality.
extends "res://addons/inventory/custom_nodes/base/slot.gd"

signal drag_started
signal drag_ended

enum DragOrigin {
	CENTER, RELATIVE, TOPLEFT
}

# warning-ignore:unused_class_variable
export var shift_quick_move: bool = true
export var next_groups: PoolStringArray = PoolStringArray()

export var drag_disabled: bool = false
export(DragOrigin) var drag_origin = DragOrigin.CENTER
export var custom_drag_origin: Vector2 = Vector2()

export var block_doubleclick: bool = false

# This will repeat the quick move function until either
# the item cannot be moved or the item is fully moved
export var repeat_group_move: bool = true

var _relative_pos: Vector2 = Vector2()
var _drag_texture_rect: TextureRect = TextureRect.new()

var _drag_item: Item = null setget set_drag_item

func _enter_tree():
	connect("gui_input", self, "slot_gui_input")
	
func _exit_tree():
	disconnect("gui_input", self, "slot_gui_input")
	
func slot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (not event.doubleclick or not block_doubleclick):
		if item != null:
			if event.button_index == BUTTON_LEFT and event.pressed:
				if event.shift and shift_quick_move and next_groups.size() > 0:
					quick_move_item()
				else:
					self._drag_item = item
					self.item = null
			elif event.button_index == BUTTON_RIGHT and event.pressed:
				if self.item.stack == 1:
					self._drag_item = item
					self.item = null
				else:
					_relative_pos = item.get_local_mouse_position()
					self._drag_item = item.split_duplicate()
					_drag_item.stack = int(item.stack / 2)
					self.item.stack -= _drag_item.stack
				
func _input(event: InputEvent) -> void:
	if _drag_item:
		if event is InputEventMouseButton:
			if not event.is_echo():
				if event.pressed and (not event.doubleclick or not block_doubleclick):
					if event.button_index == BUTTON_LEFT:
						_drop()
						# Prevent immediate picking up of the item
						get_tree().set_input_as_handled()
					elif event.button_index == BUTTON_RIGHT:
						_drop_single()
						# Prevent immediate picking up of the item
						get_tree().set_input_as_handled()
				
func _process(delta: float) -> void:
	if _drag_item:
		match drag_origin:
			DragOrigin.TOPLEFT:
				_drag_item.rect_global_position = get_global_mouse_position() + custom_drag_origin
			DragOrigin.CENTER:                                                    
				_drag_item.rect_global_position = get_global_mouse_position() - _drag_item.rect_size / 2 + custom_drag_origin
			DragOrigin.RELATIVE:
				_drag_item.rect_global_position = get_global_mouse_position() - _relative_pos + custom_drag_origin
		
func _drop():
	if not _drag_item:
		return
		
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if can_move_item(_drag_item, slot):
				var temp = _drag_item
				move_drag_item_to_slot(slot)
				return
		
	# If it gets this far then no slots were clicked and item must return
	if _drag_item:
		if item == null:
			self.item = _drag_item
			self._drag_item = null
		elif item.item_name == _drag_item.item_name:
			if _drag_item.stack + item.stack <= item.max_stack:
				self.item.stack += _drag_item.stack
				self._drag_item.queue_free()
				self._drag_item = null
			else:
				var diff: int = item.max_stack - item.stack
				self.item.stack += diff
				_drag_item.stack -= diff
		# Otherwise cannot return because item and _drag_item
		# are different types
		
func _drop_single() -> void:
	if not _drag_item:
		return
		
	var inst = _drag_item.split_duplicate()
		
	for slot in get_tree().get_nodes_in_group("inventory_slots"):
		if slot.get_global_rect().has_point(get_global_mouse_position()):
			if can_move_item(inst, slot):
				if slot.confine_categories.size() == 0 or _drag_item.has_category_overlap(slot.confine_categories):
					if slot.item:
						if confine_categories.size() == 0 or slot.item.has_category_overlap(confine_categories):
							if _drag_item.item_name == slot.item.item_name:
								if slot.item.stack + 1 < slot.item.max_stack:
									slot.item.stack += 1
									_drag_item.stack -= 1
									if _drag_item.stack <= 0:
										_drag_item.queue_free()
										self._drag_item = null
									item_moved(inst, slot)
									inst.queue_free()
									break
					else:
						inst.stack = 1
						slot.item = inst
						
						_drag_item.stack -= 1
						if _drag_item.stack <= 0:
							_drag_item.queue_free()
							self._drag_item = null
						item_moved(inst, slot)
						break
						
func _find_valid_slot(for_item: Item, groups:PoolStringArray) -> PanelContainer:
	for gr in groups:
		for slot in get_tree().get_nodes_in_group(gr):
			if slot.confine_categories.size() == 0 or item.has_category_overlap(slot.confine_categories):
				if not slot.item or (slot.item.item_name == for_item.item_name and not slot.item.is_full()):
					if can_move_item(for_item, slot):
						return slot
	
	return null
	
func set_drag_item(to: Item) -> void:
	if _drag_item:
		_drag_item.set_as_toplevel(false)
		queue_sort()
		
	_drag_item = to
	
	if _drag_item and _drag_item.is_inside_tree():
		_relative_pos = _drag_item.get_local_mouse_position()
		_drag_item.get_parent().remove_child(_drag_item)
	
	if _drag_item:
		add_child(_drag_item)
		_drag_item.set_as_toplevel(true)
		emit_signal("drag_started")
	else:
		queue_sort()
		emit_signal("drag_ended")
		
func move_drag_item_to_slot(slot) -> void:
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
						item_moved(_drag_item, slot)
						self._drag_item = null
					# Otherwise either the stack is full or only partial can be added
					else:
						# If it is full
						if slot.item.is_full():
							var temp = slot.item
							slot.item = _drag_item
							slot._drag_item = temp
							# If swapping with self don't stop drag
							if slot != self:
								self._drag_item = null
							item_moved(_drag_item, slot)
						# Add partial
						else:
							var diff: int = slot.item.max_stack - slot.item.stack
							slot.item.stack += diff
							_drag_item.stack -= diff
							item_moved(_drag_item, slot)
				# If moving to a slot with a different item
				else:
					# If no item in this slot just swap
					if item == null:
						var temp = self._drag_item
						self._drag_item = slot.item
						slot.item = temp
						item_moved(_drag_item, slot)
					else:
						var temp = slot.item
						slot.item = _drag_item
						# If swapping with self don't stop drag
						if slot != self:
							self._drag_item = null
						slot._drag_item = temp
						item_moved(_drag_item, slot)
				
		# Otherwise if the slot is empty just move the item
		else:
			slot.item = _drag_item
			item_moved(_drag_item, slot)
			self._drag_item = null
			
func move_item_to_drag_item(slot) -> void:
	if not item or not slot._drag_item:
		return
		
	if slot.confine_categories.size() == 0 or item.has_category_overlap(slot.confine_categories):
		# Both slots must support the items that will swap
		if confine_categories.size() == 0 or slot._drag_item.has_category_overlap(confine_categories):
			if item.item_name == slot._drag_item.item_name:
				if item.stack + slot._drag_item.stack <= slot._drag_item.max_stack:
					self.item.queue_free()
					slot._drag_item.stack += self.item.stack
					self.item = null
				# Otherwise either the stack is full or only partial can be added
				else:
					# Add partial
					if slot._drag_item.stack < slot._drag_item.max_stack:
						var diff: int = slot._drag_item.max_stack - slot._drag_item.stack
						slot._drag_item.stack += diff
						self.item.stack -= diff
						
func quick_move_item() -> void:
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
		
func collect_items_to_drag(groups: PoolStringArray) -> void:
	for gr in groups:
		for slot in get_tree().get_nodes_in_group(gr):
			if slot != self and slot.item and _drag_item and slot.item.item_name == _drag_item.item_name and not slot.item.is_full():
				slot.move_item_to_drag_item(self)
				
func collect_items(groups: PoolStringArray) -> void:
	for gr in groups:
		for slot in get_tree().get_nodes_in_group(gr):
			if slot != self and slot.item and item and slot.item.item_name == item.item_name and not slot.item.is_full():
				slot.move_item_to_slot(self)
