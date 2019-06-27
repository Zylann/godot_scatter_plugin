tool
extends Control

signal pattern_selected(pattern_index)
signal pattern_added(path)
signal pattern_removed(path)

onready var _item_list = get_node("VBoxContainer/ItemList")

var _file_dialog = null
var _error_dialog = null


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.tscn ; TSCN files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)
	
	_error_dialog = AcceptDialog.new()
	_error_dialog.rect_min_size = Vector2(300, 200)
	_error_dialog.hide()
	base_control.add_child(_error_dialog)


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func load_patterns(patterns):
	_item_list.clear()
	#print("Loading ", len(patterns), " patterns")
	for scene in patterns:
		var i = _item_list.get_item_count()
		_add_pattern_from_path(scene.resource_path)


func _add_pattern_from_path(scene_path):
	# TODO I need scene thumbnails from the editor
	var default_icon = get_icon("PackedScene", "EditorIcons")
	var pattern_name = scene_path.get_file()
	var i = _item_list.get_item_count()
	_item_list.add_item(pattern_name, default_icon)
	_item_list.set_item_metadata(i, scene_path)


func _on_ItemList_item_selected(index):
	emit_signal("pattern_selected", index)


func _on_AddButton_pressed():
	_file_dialog.popup_centered_ratio(0.7)


func _on_RemoveButton_pressed():
	var selected_items = _item_list.get_selected_items()
	if len(selected_items) == 0:
		return
	var i = selected_items[0]
	var scene_path = _item_list.get_item_metadata(i)
	emit_signal("pattern_removed", scene_path)
	_item_list.remove_item(i)


func _on_FileDialog_file_selected(fpath):
	if verify_scene(fpath):
		print("Adding pattern ", fpath)
		emit_signal("pattern_added", fpath)
		_add_pattern_from_path(fpath)


func _show_error(msg):
	_error_dialog.dialog_text = msg
	_error_dialog.popup_centered_minsize()


func verify_scene(fpath):
	var scene = load(fpath)
	if scene == null:
		_show_error(tr("Could not load the scene. See the console for more info."))
		return false
#	var scene_state = scene.get_state()
#	var root_type = scene_state.get_node_type(0)
	# Aaaah screw this
	var scene_instance = scene.instance()
	if scene_instance is Spatial:
		scene_instance.free()
		return true
	scene_instance.free()
	_show_error(tr("The selected scene is not a Spatial, it can't be painted in a 3D scene."))
	return false

