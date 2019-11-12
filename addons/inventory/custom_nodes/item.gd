tool
extends TextureRect
class_name Item

signal stack_changed

# The unique name of an item, used for stacking
# warning-ignore:unused_class_variable
var item_name: String = "item_name"

var categories: PoolStringArray = PoolStringArray()

var stack: int = 1 setget set_stack
var max_stack: int = 99 setget set_stack

func _init():
	expand = true
	mouse_filter = MOUSE_FILTER_IGNORE

func has_category_overlap(other_categories: PoolStringArray) -> bool:
	for c1 in other_categories:
		for c2 in categories:
			if c1 == c2:
				return true
				
	return false

func set_stack(to: int) -> void:
	stack = to
	if stack > max_stack:
		stack = max_stack
	emit_signal("stack_changed")
	
func set_max_stack(to: int) -> void:
	max_stack = to
	if stack > max_stack:
		self.stack = max_stack

func split_duplicate() -> TextureRect:
	var dup: TextureRect = get_script().new()
	dup.rect_size = rect_size
	return dup
	
func is_full() -> bool:
	return max_stack == stack
