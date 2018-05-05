tool
extends Sprite

signal mouse_entered
signal mouse_exited

const DragRect2 = preload("res://addons/inventory/helpers/drag_rect2.gd")
const AreaRect2 = preload("res://addons/inventory/helpers/area_rect2.gd")
const RECT_COLOR_AREA = Color("3FC380")
const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false

var mouse_over = false

func _ready():
	add_to_group("inventory_nodes")
	
func mouse_over(group="inventory_nodes"):
	"""Return a list of nodes in the group (default "inventory_nodes") with mouse_over"""
	var arr = []
	for node in get_tree().get_nodes_in_group(group):
		if node.mouse_over:
			arr.append(node)
	return arr
	
func node_dragging(group="inventory_nodes"):
	"""Return the current node in the group (default "inventory_nodes") that are dragging"""
	for node in get_tree().get_nodes_in_group(group):
		if node.dragging:
			return node
	
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
	
func global_z_index():
	"""Return the total z_index of this instance and all of its ancestors combined"""
	var node = self
	var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	var total = 0
	while node != main:
		total += node.z_index
		node = node.get_parent()
	return total
	
func items_no_slot():
	"""Returns a list of inventory_items that are not in a slot"""
	var arr = []
	for node in get_tree().get_nodes_in_group("inventory_items"):
		if not node.slot:
			arr.append(node)
	return arr
	
func make_top():
	"""Orders all inventory_nodes by their z_index and makes self the top z_index"""
	var all_nodes = get_tree().get_nodes_in_group("inventories") + items_no_slot()
	var nodes = []
	for inst in all_nodes:
		if inst != self:
			var index = len(nodes)-1
			while not inst in nodes:
				if not len(nodes):
					nodes.append(inst)
				elif inst.z_index < nodes[index].z_index:
					nodes.insert(index, inst)
				elif inst.z_index >= nodes[index].z_index:
					nodes.insert(index+1, inst)
				index += 1
	nodes.append(self)
	for i in len(nodes):
		nodes[i].z_index = i