tool
extends EditorPlugin

const Slot: GDScript = preload("res://addons/inventory/custom_nodes/slot.gd")
const DragSlot: GDScript = preload("res://addons/inventory/custom_nodes/drag_slot.gd")

func _enter_tree() -> void:
	add_custom_type("Slot", "PanelContainer", Slot, null)
	add_custom_type("DragSlot", "PanelContainer", DragSlot, null)

func _exit_tree() -> void:
	remove_custom_type("Slot")
	remove_custom_type("DragSlot")
