tool
extends Spatial


# TODO Serialize packed scenes
var _scenes = []


func _ready():
	# TODO Temporary test
	_scenes.append(load("res://tests/props/placeholder_tree.tscn"))
	# Remove null scenes in case they failed to load for some reason
	var i = 0
	while i < len(_scenes):
		if _scenes[i] == null:
			printerr(get_path(), ": Scene ", i, " failed to load")
			_scenes.remove(i)
		else:
			i += 1


func get_patterns():
	return _scenes


func add_pattern(path):
	_scenes.append(load(path))


func remove_pattern(path):
	for i in len(_scenes):
		if _scenes[i].resource_path == path:
			_scenes.remove(i)
			break

