tool
extends Sprite

# Mouse signals
signal mouse_enter
signal mouse_exit

var mouse_over = false

const RECT_COLOR_DROP = Color("3FC380")
const RECT_COLOR_DRAG = Color("22A7F0")
const RECT_FILLED = false

func _ready():
	add_to_group("inventory_nodes")
	
func mouse_over_group(group="inventory_nodes"):
	var arr = []
	for node in get_tree().get_nodes_in_group(group):
		if node.mouse_over:
			arr.append(node)
	return arr
	
func node_dragging(group="inventory_nodes"):
	var arr = []
	for node in get_tree().get_nodes_in_group(group):
		if node.dragging:
			return node
	
func top(group="inventory_nodes", mouse_over=true):
	var top = null
	for node in get_tree().get_nodes_in_group(group):
		if node.mouse_over or not mouse_over:
			if not top:
				top = node
			elif node.global_z_index() > top.global_z_index():
				top = node
	return top
	
func global_z_index():
	var node = self
	var main = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	var total = 0
	while node != main:
		total += node.z_index
		node = node.get_parent()
	return total
	
func items_no_slot():
	var arr = []
	for node in get_tree().get_nodes_in_group("inventory_items"):
		if not node.slot:
			arr.append(node)
	return arr
	
func make_top():
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