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

var item: Item = null setget set_item

var _texture_rect = TextureRect.new()

func _enter_tree() -> void:
	add_to_group("inventory_slots")
	get_texture_rect().expand = true
	add_child(get_texture_rect())
	move_child(get_texture_rect(), 0)

func set_item(to: Item) -> void:
	item = to
	
	if item:
		get_texture_rect().texture = item.get_item_texture()
		emit_signal("item_added")
	else:
		get_texture_rect().texture = null
		emit_signal("item_removed")

func get_texture_rect() -> TextureRect:
	return _texture_rect
	
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
