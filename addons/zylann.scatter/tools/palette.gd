tool
extends Control

const Logger = preload("../util/logger.gd")

signal patterns_selected(pattern_paths)
signal pattern_added(path)
signal patterns_removed(path)

onready var _item_list : ItemList = get_node("VBoxContainer/ItemList")
onready var _margin_spin_box : SpinBox = get_node("VBoxContainer/MarginContainer/MarginSpinBox")

var _file_dialog = null
var _preview_provider : EditorResourcePreview = null
var _logger = Logger.get_for(self)


func setup_dialogs(base_control):
	_file_dialog = FileDialog.new()
	_file_dialog.access = FileDialog.ACCESS_RESOURCES
	_file_dialog.mode = FileDialog.MODE_OPEN_FILE
	_file_dialog.add_filter("*.tscn ; TSCN files")
	_file_dialog.connect("file_selected", self, "_on_FileDialog_file_selected")
	_file_dialog.hide()
	base_control.add_child(_file_dialog)


func set_preview_provider(provider : EditorResourcePreview):
	assert(_preview_provider == null)
	assert(provider != null)
	_preview_provider = provider
	_preview_provider.connect("preview_invalidated", self, "_on_EditorResourcePreview_preview_invalidated")


func _exit_tree():
	if _file_dialog != null:
		_file_dialog.queue_free()
		_file_dialog = null


func load_patterns(patterns):
	_item_list.clear()
	#print("Loading ", len(patterns), " patterns")
	for scene in patterns:
		add_pattern(scene.resource_path)


func add_pattern(scene_path):
	# TODO I need scene thumbnails from the editor
	var default_icon = get_icon("PackedScene", "EditorIcons")
	var pattern_name = scene_path.get_file().get_basename()
	var i = _item_list.get_item_count()
	_item_list.add_item(pattern_name, default_icon)
	_item_list.set_item_metadata(i, scene_path)
	
	_preview_provider.queue_resource_preview( \
		scene_path, self, "_on_EditorResourcePreview_preview_loaded", null)


func _on_EditorResourcePreview_preview_loaded(path, texture, userdata):
	var i = find_pattern(path)
	if i == -1:
		return
	if texture != null:
		_item_list.set_item_icon(i, texture)
	else:
		_logger.debug(str("No preview available for ", path))


func _on_EditorResourcePreview_preview_invalidated(path):
	# TODO Handle thumbnail invalidation
	#`path` is actually the folder in which the file was, NOT the file itself... useful for FileSystemDock only :(
	pass


func remove_pattern(scene_path):
	var i = find_pattern(scene_path)
	if i != -1:
		_item_list.remove_item(i)


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


func _on_ItemList_multi_selected(_unused_index, _unused_selected):
	var selected = []
	for item in _item_list.get_selected_items():
		selected.append(_item_list.get_item_metadata(item))
	emit_signal("patterns_selected", selected)


func get_configured_margin() -> float:
	return _margin_spin_box.value


func _on_AddButton_pressed():
	_file_dialog.popup_centered_ratio(0.7)


func _on_RemoveButton_pressed():
	var removed := []
	for item in _item_list.get_selected_items():
		removed.append(_item_list.get_item_metadata(item))
	emit_signal("patterns_removed", removed)


func _on_FileDialog_file_selected(fpath):
	emit_signal("pattern_added", fpath)


func can_drop_data(position, data):
	return data is Dictionary and data.get("type") == "files"


func drop_data(position, data):
	for file in data.files:
		emit_signal("pattern_added", file)
