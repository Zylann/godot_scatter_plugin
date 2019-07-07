tool
extends Control

signal pattern_selected(pattern_index)
signal pattern_added(path)
signal pattern_removed(path)

onready var _item_list = get_node("VBoxContainer/ItemList")

var _file_dialog = null


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.tscn ; TSCN files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func load_patterns(patterns):
	var selected_pattern = get_selected_pattern()
	_item_list.clear()
	#print("Loading ", len(patterns), " patterns")
	for scene in patterns:
		add_pattern(scene.resource_path)
	if selected_pattern != null:
		var i = find_pattern(selected_pattern.path)
		if i != -1:
			_item_list.select(i)


func add_pattern(scene_path):
	# TODO I need scene thumbnails from the editor
	var default_icon = get_icon("PackedScene", "EditorIcons")
	var pattern_name = scene_path.get_file()
	var i = _item_list.get_item_count()
	_item_list.add_item(pattern_name, default_icon)
	_item_list.set_item_metadata(i, scene_path)


func remove_pattern(scene_path):
	var i = find_pattern(scene_path)
	if i != -1:
		_item_list.remove_item(i)


func get_selected_pattern():
	var selected_items = _item_list.get_selected_items()
	if len(selected_items) == 0:
		return null
	var i = selected_items[0]
	var scene_path = _item_list.get_item_metadata(i)
	return {
		"index": i,
		"path": scene_path
	}


func find_pattern(path):
	for i in _item_list.get_item_count():
		var scene_path = _item_list.get_item_metadata(i)
		if scene_path == path:
			return i
	return -1


func select_pattern(path):
	var i = find_pattern(path)
	if i != -1:
		_item_list.select(i)


func _on_ItemList_item_selected(index):
	emit_signal("pattern_selected", index)


func _on_AddButton_pressed():
	_file_dialog.popup_centered_ratio(0.7)


func _on_RemoveButton_pressed():
	var s = get_selected_pattern()
	if s == null:
		return
	emit_signal("pattern_removed", s.path)


func _on_FileDialog_file_selected(fpath):
	emit_signal("pattern_added", fpath)


