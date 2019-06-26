tool
extends Control

signal pattern_selected(pattern_index)

onready var _item_list = get_node("VBoxContainer/ItemList")

var _file_dialog = null


func setup_dialogs(base_control):
	# TODO
	pass


func load_patterns(patterns):
	_item_list.clear()
	# TODO I need scene thumbnails from the editor
	var default_icon = get_icon("PackedScene", "EditorIcons")
	#print("Loading ", len(patterns), " patterns")
	for scene in patterns:
		var i = _item_list.get_item_count()
		var scene_path = scene.resource_path
		var pattern_name = scene_path.get_file()
		_item_list.add_item(pattern_name, default_icon)
		#_item_list.set_item_metadata(i, i)


func _on_ItemList_item_selected(index):
	emit_signal("pattern_selected", index)


func _on_AddButton_pressed():
	# TODO
	pass # Replace with function body.


func _on_RemoveButton_pressed():
	# TODO
	pass # Replace with function body.

