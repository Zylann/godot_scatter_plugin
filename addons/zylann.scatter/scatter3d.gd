tool
extends Spatial


export(Array, PackedScene) var _scenes = []


func _ready():
	_remove_dangling_patterns()


func _remove_dangling_patterns():
	# Remove null scenes in case they failed to load for some reason
	var changed = false
	var i = 0
	while i < len(_scenes):
		if _scenes[i] == null:
			printerr(get_path(), ": Scene ", i, " failed to load")
			_scenes.remove(i)
			changed = true
		else:
			i += 1
	if changed:
		property_list_changed_notify()


func get_patterns():
	return _scenes


func add_pattern(path):
	_scenes.append(load(path))
	property_list_changed_notify()


func remove_pattern(path):
	for i in len(_scenes):
		if _scenes[i].resource_path == path:
			_scenes.remove(i)
			property_list_changed_notify()
			break


func has_pattern(path):
	for scene in _scenes:
		if scene.resource_path == path:
			return true
	return false
