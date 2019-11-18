extends "res://addons/inventory/custom_nodes/drag_slot.gd"

func slot_gui_input(event) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.doubleclick:
			collect_items_to_drag(["main", "toolbar"])
			return
			
	.slot_gui_input(event)
