extends Control

var current_index := 0
var children_list := []
var has_unselected_once := false
@onready var selected = null


func _ready():
	if Global.can_select:
		children_list = get_children()
		highlight_selected()

func set_yallow(object : NinePatchRect):
	object.self_modulate = Color("ffdd00")
	current_index = 0
	
	
	pass

func _unhandled_key_input(event: InputEvent):
	if Global.can_select:
		has_unselected_once = false
		if event is InputEventKey and event.pressed:
			if event.keycode == KEY_RIGHT:
				current_index += 1
				if current_index >= children_list.size():
					current_index = 0
				highlight_selected()
			elif event.keycode == KEY_LEFT:
				current_index -= 1
				if current_index < 0:
					current_index = children_list.size() - 1
				highlight_selected()
	else:
		selected.self_modulate = Color.WHITE
		has_unselected_once = true

func highlight_selected():
	for i in children_list.size():
		var child = children_list[i]
		if child is CanvasItem:
			if i == current_index:
				child.self_modulate = Color("ffdd00")
				selected = child
				Global.current_options = child.name
			else:
				child.self_modulate = Color.WHITE
