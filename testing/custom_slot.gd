extends "res://addons/inventory/custom_nodes/drag_slot.gd"

var _label = Label.new()
var _drag_label = Label.new()

func _enter_tree():
	get_label().size_flags_horizontal = SIZE_SHRINK_END
	get_label().size_flags_vertical = SIZE_SHRINK_END
	get_texture_rect().add_child(get_label())
	
	get_drag_lable().size_flags_horizontal = SIZE_SHRINK_END
	get_drag_lable().size_flags_vertical = SIZE_SHRINK_END
	get_drag_texture_rect().add_child(get_drag_lable())
	
	# warning-ignore:return_value_discarded
	connect("drag_started", self, "_on_drag_started")
	# warning-ignore:return_value_discarded
	connect("drag_ended", self, "_on_drag_ended")
	
	# warning-ignore:return_value_discarded
	connect("item_added", self, "_on_item_added")
	# warning-ignore:return_value_discarded
	connect("item_removed", self, "_on_item_removed")
	
func _exit_tree():
	disconnect("drag_started", self, "_on_drag_started")
	disconnect("drag_ended", self, "_on_drag_ended")
	
	disconnect("item_added", self, "_on_item_added")
	disconnect("item_removed", self, "_on_item_removed")
	
func _on_drag_started():
	if _drag_item and not _drag_item.is_connected("stack_changed", self, "_update_labels"):
		# warning-ignore:return_value_discarded
		_drag_item.connect("stack_changed", self, "_update_labels")
		
	_update_labels()
	
func _on_drag_ended():
	if _drag_item and _drag_item.is_connected("stack_changed", self, "_update_labels"):
		_drag_item.disconnect("stack_changed", self, "_update_labels")
		
	_update_labels()

func _on_item_added():
	if item and not item.is_connected("stack_changed", self, "_update_labels"):
# warning-ignore:return_value_discarded
		item.connect("stack_changed", self, "_update_labels")
		
	_update_labels()

func _on_item_removed():
	if item and item.is_connected("stack_changed", self, "_update_labels"):
		item.disconnect("stack_changed", self, "_update_labels")
		
	get_label().visible = false
	
func _update_labels() -> void:
	if item != null:
		get_label().visible = true
		get_label().text = str(item.stack)
		get_label().set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)
	
	if _drag_item != null:
		get_drag_lable().text = str(_drag_item.stack)
		get_drag_lable().set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)
	
func get_label():
	return _label
	
func get_drag_lable():
	return _drag_label
