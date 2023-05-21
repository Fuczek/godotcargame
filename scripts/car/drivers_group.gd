extends Node

func clear_active_cars():
	var children_list = self.get_children()
	if self.get_children():
		for node in children_list:
			var node_groups = node.get_groups()
			for group in node_groups:
				node.remove_from_group(group)
			node.queue_free()
