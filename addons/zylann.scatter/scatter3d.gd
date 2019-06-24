tool
extends Spatial


#export var group = "scatter_environment"

var _scenes = []


func _ready():
	# TODO Temporary test
	_scenes.append(load("res://tests/props/placeholder_tree.tscn"))


func get_patterns():
	return _scenes
