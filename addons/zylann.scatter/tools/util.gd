
static func get_scene_aabb(node, aabb=AABB()):
	if not node.visible:
		return aabb
	if node is VisualInstance:
		var node_aabb = node.global_transform.xform(node.get_aabb())
		if aabb == AABB():
			aabb = node_aabb
		else:
			aabb = aabb.merge(node_aabb)
	for i in node.get_child_count():
		aabb = get_scene_aabb(node.get_child(i), aabb)
	return aabb


static func get_instance_root(node):
	# TODO Could use `owner`?
	while node != null and node.filename == "":
		node = node.get_parent()
	return node


static func get_node_in_parents(node, klass):
	while node != null:
		node = node.get_parent()
		if node != null and node is klass:
			return node
	return null


static func is_self_or_parent_scene(fpath, node):
	while node != null:
		if node.filename == fpath:
			return true
		node = node.get_parent()
	return false


