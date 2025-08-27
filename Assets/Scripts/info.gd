extends Control

signal item_selected(value)

var current_index := 0
var children_list := []
var input_enabled := true

var item_list = [
	{ "text": "Item 1", "value": 100 },
	{ "text": "Item 2", "value": 200 },
	{ "text": "Item 3", "value": 300 },
	{ "text": "Item 4", "value": 400 }
]


func _ready():
	_Item()
	children_list = get_children()
	highlight_selected()
	

func _Item():
	for item_data in item_list:
		var item_label = Label.new()
		item_label.text = item_data["text"]
		item_label.label_settings = load("res://Assets/tress/LabelSetting/debug_2.tres")
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		item_label.set_meta("value", item_data["value"])
		add_child(item_label)

func _process(delta: float) -> void:
	input_enabled = Global.can_select_item

func _unhandled_key_input(event: InputEvent):
	if not input_enabled:
		return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN:
			current_index += 1
			if current_index >= children_list.size():
				current_index = 0
			highlight_selected()
		elif event.keycode == KEY_UP:
			current_index -= 1
			if current_index < 0:
				current_index = children_list.size() - 1
			highlight_selected()
		elif Input.is_action_just_pressed("confirm"):
			input_enabled = false
			var selected_item = children_list[current_index]
			var value = selected_item.get_meta("value")
			emit_signal("item_selected", value)

func wait_for_selection() -> Variant:
	input_enabled = true
	var value = await self.item_selected
	return value


func highlight_selected():
	for i in children_list.size():
		var child = children_list[i]
		if child is CanvasItem:
			child.modulate = (Color("ffdd00") if i == current_index else Color.WHITE)
			if i == current_index:Global.selected_item = child.text
