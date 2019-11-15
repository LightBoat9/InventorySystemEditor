tool
extends HBoxContainer

export var amount = 0 setget set_amount

func set_amount(to: int) -> void:
	amount = to
	$Label.text = str(to)
