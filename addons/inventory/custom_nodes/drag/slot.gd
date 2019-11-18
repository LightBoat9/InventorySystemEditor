tool
extends PanelContainer

signal item_added
signal item_removed

# The categories that this slot can hold. Should not be directly modified through
# script as PoolArrays are passed by value not reference. Instead see 
# add_confine_category and remove_confine_categor
export var confine_categories: PoolStringArray = PoolStringArray()

# warning-ignore:unused_class_variable
export var slot_group: String = "" setget set_slot_group

var item: Item = null setget set_item, get_item

func _enter_tree() -> void:
	add_to_group("inventory_slots")

func set_item(to: Item) -> void:
	if item == to:
		return
		
	item = to
	
	if item and item.is_inside_tree():
		item.get_parent().remove_child(item)
	
	if item:
		add_child(item)
		item.set_as_toplevel(false)
		queue_sort()
	
	if item:
		emit_signal("item_added")
	else:
		emit_signal("item_removed")
		
func get_item() -> Item:
	return item
	
func add_confine_category(cat: String) -> void:
	confine_categories.append(cat)
	
func remove_confine_category(cat: String) -> void:
	for i in range(confine_categories.size()):
		if confine_categories[i] == cat:
			confine_categories.remove(i)
			return
			
func set_slot_group(to: String) -> void:
	if to and is_in_group(to):
		remove_from_group(to)

	slot_group = to

	if slot_group and not is_in_group(slot_group):
		add_to_group(slot_group)
		
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
		if item.stack + slot.item.stack <= slot.item.max_stack:
			item.queue_free()
			slot.item.stack += item.stack
			item_moved(item, slot)
			self.item = null
		# Otherwise either the stack is full or only partial can be added
		else:
			# Add partial
			if slot.item.stack != slot.item.max_stack:
				var diff: int = slot.item.max_stack - slot.item.stack
				slot.item.stack += diff
				self.item.stack -= diff
				item_moved(item, slot)
	else:
		slot.item = item
		item_moved(item, slot)
		self.item = null
		
func can_move_item(item, slot) -> bool:
	return true
	
func item_moved(item, slot) -> void:
	pass
