extends "res://addons/inventory/custom_nodes/drag_slot.gd"

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

func _on_DragSlot_item_removed():
	tooltip_layer.visible = false
