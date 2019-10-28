extends "res://addons/inventory/custom_nodes/drag_slot.gd"

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed and event.doubleclick:
				_set_is_dragging(false)
				_drop()
				get_tree().set_input_as_handled()
