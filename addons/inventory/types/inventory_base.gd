tool
extends Sprite
	
func top_node(group="inventory_nodes", mouse_over=true, not_self=true):
	"""Return the top (highest z_index) node in the group (default "inventory_nodes").
	
		(bool) mouse_over : only check items with mouse_over.
		(bool) not_self : only check items that are not self.
	"""
	var top = null
	for node in get_tree().get_nodes_in_group(group):
		if (node.mouse_over or not mouse_over) and (node != self or not not_self):
			if not top:
				top = node
			elif node.global_z_index() > top.global_z_index():
				top = node
	return top
	
func items_no_slot():
	"""Returns a list of inventory_items that are not in a slot"""
	var arr = []
	for node in get_tree().get_nodes_in_group("inventory_items"):
		if not node.slot:
			arr.append(node)
	return arr