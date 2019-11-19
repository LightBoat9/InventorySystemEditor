extends "res://addons/inventory/custom_nodes/drag/drag_slot.gd"

onready var tooltip_layer = $Layer

func _on_DragSlot_mouse_entered():
	if item:
		$TooltipTimer.start()

func _on_DragSlot_mouse_exited():
	tooltip_layer.visible = false
	$TooltipTimer.stop()

func _on_TooltipTimer_timeout():
	if item:
		tooltip_layer.visible = true

func _on_DragSlot_item_added():
	if item:
		$Layer/CustomTooltip/VBoxContainer/Label.text = item.item_name
		$Layer/CustomTooltip/VBoxContainer/CoinContainer.amount = item.cost

func _on_DragSlot_item_removed():
	tooltip_layer.visible = false
	
func can_move_item(item, slot) -> bool:
	if slot_group == "shop" and slot.slot_group == "main":
		if get_owner().coins >= item.stack * item.cost:
			return true
	elif slot_group == "main" and slot.slot_group == "shop":
		return true
		
	return slot.is_in_group(slot_group)
	
func item_moved(item, slot) -> void:
	if slot_group == "shop" and slot.slot_group == "main":
		get_owner().coins -= item.stack * item.cost
		get_owner().shop_coins += item.stack * item.cost
	elif slot_group == "main" and slot.slot_group == "shop":
		get_owner().coins += item.stack * item.cost
		get_owner().shop_coins -= item.stack * item.cost
