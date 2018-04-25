extends Node

func _ready():
	var node = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	node.get_node("Inventory").connect("item_dropped", self, "_item_dropped")
	
func _item_dropped(item):
	get_parent().add_item(item)