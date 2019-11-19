tool
extends "res://addons/inventory/custom_nodes/space/space_inventory.gd"

var rc_item: SpaceItem

func slot_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_RIGHT and event.pressed:
			rc_item = get_item_at((event.position / slot_size).floor())
			$PopupMenu.popup(Rect2(event.global_position, $PopupMenu.rect_size))
			return
			
	.slot_gui_input(event)

func _on_PopupMenu_index_pressed(index):
	match index:
		0:
			split_and_drag(rc_item)
