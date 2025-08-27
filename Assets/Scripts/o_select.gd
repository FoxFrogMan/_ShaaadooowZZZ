extends Node2D

signal saved

var can_save = false
var current_index := 0
var children_list: Array = []
var saved_flags: Array[bool] = []
var can_select = true


func _ready():
	Global.can_move = false
	children_list = get_children()
	saved_flags.resize(children_list.size())
	
	
	for i in range(children_list.size()):
		if i < Global.saves.size():
			saved_flags[i] = true
		else:
			saved_flags[i] = false
	
	update_labels()
	current_index = 0
	highlight_selected()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_DOWN and can_select:
			move_selection(1)
		elif event.keycode == KEY_UP and can_select:
			move_selection(-1)
		elif Input.is_action_just_pressed("confirm") and can_save:
			if saved_flags[current_index]:
				emit_signal("saved")
				$"..".queue_free()
			else:
				save_at_slot(current_index)
		if Input.is_action_just_pressed("confirm") and !can_save:
			can_save = true

func save_at_slot(slot: int) -> void:
	if slot < 0 or slot >= children_list.size():
		return
	
	var child = children_list[slot]
	var time_str = get_time_string()
	
	if slot < Global.saves.size():
		Global.saves[slot] = time_str
	else:
		Global.saves.append(time_str)
	
	saved_flags[slot] = true
	child.get_node("Label").text = "File Saved"
	can_select = false
	highlight_selected()

func move_selection(direction: int) -> void:
	var size = children_list.size()
	current_index = (current_index + direction + size) % size
	highlight_selected()

func highlight_selected():
	for i in range(children_list.size()):
		var child = children_list[i]
		if child is CanvasItem:
			if i == current_index:
				child.modulate = Color("ffdd00")
			else:
				child.modulate = Color.WHITE

func update_labels():
	for i in range(children_list.size()):
		var child = children_list[i]
		if i < Global.saves.size():
			child.get_node("Label").text = Global.saves[i]
		else:
			child.get_node("Label").text = "Empty Slot"

func get_time_string() -> String:
	var time = Time.get_datetime_dict_from_system()
	return str(time.hour).pad_zeros(2) + ":" + str(time.minute).pad_zeros(2)
