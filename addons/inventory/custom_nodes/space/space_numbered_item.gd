extends SpaceItem
class_name SpaceNumberedItem

var _number_label: Label = Label.new()

func _init().():
	get_number_label().text = str(stack)
	add_child(get_number_label())
	get_number_label().set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)

func set_stack(to: int) -> void:
	.set_stack(to)
	get_number_label().text = str(stack)
	get_number_label().set_anchors_and_margins_preset(Control.PRESET_BOTTOM_RIGHT)

func get_number_label() -> Label:
	return _number_label
