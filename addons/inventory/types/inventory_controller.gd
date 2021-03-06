extends Node

func get_top(ignore_nodes=[], group="inventory_nodes", mouse_over=true):
	"""
		Return the top (highest in tree) node in the group (default "inventory_nodes") or null if there
		is no top node.
	
		(bool) mouse_over : only check items with mouse_over.
		(bool) ignore_nodes : only check items that are not self.
	"""
	var top = null
	for node in get_tree().get_nodes_in_group(group):
		if (node.mouse_over or not mouse_over) and (not node in ignore_nodes):
			if not top:
				top = node
			elif node.is_greater_than(top):
				top = node
	return top
	
func is_top(node):
	var nodes = get_tree().get_nodes_in_group("inventory_nodes")
	for inst in nodes:
		if inst.mouse_over and inst.is_greater_than(node):
			return false
	return true
	
func make_top(node):
	"""Orders all inventory_nodes by their current position and makes self the top"""
	var all_nodes = get_tree().get_nodes_in_group("inventory_nodes")
	var nodes = []
	for inst in all_nodes:
		if inst != node:
			var index = len(nodes)-1
			while not inst in nodes:
				if not len(nodes):
					nodes.append(inst)
				elif not inst.is_greater_than(nodes[index]):
					nodes.insert(index, inst)
				elif inst.is_greater_than(nodes[index]):
					nodes.insert(index+1, inst)
				index += 1
	nodes.append(node)
	for i in len(nodes):
		nodes[i].raise()
	
func current_dragging():
	var nodes = get_tree().get_nodes_in_group("inventory_nodes")
	for node in nodes:
		if node.dragging:
			return node
			
func set_debug_mode(in_game, in_editor, ignore_groups=[], ignore_nodes=[]):
	"""
		Set the debug_in_editor and debug_in_game of all inventory_nodes.
	
		(bool) in_game : value to set for debug_in_game.
		(bool) in_editor : value to set for debug_in_editor.
		(Array) ignore_groups : list of groups to ignore
		(Array) ignore_nodes : list of nodes to ignore
	"""
	var nodes = get_tree().get_nodes_in_group("inventory_nodes")
	var ignore = false
	for node in nodes:
		for group in ignore_groups:
			if node.is_in_group(group):
				ignore = true
				continue
		if not node in ignore_nodes and not ignore:
			node.debug_in_game = in_game
			node.debug_in_editor = in_editor
	