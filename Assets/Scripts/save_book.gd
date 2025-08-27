extends Node2D

var in_side := false
var save_menu: Node = null

func _process(delta: float) -> void:
	if in_side and Input.is_action_just_pressed("confirm") and Global.can_move:
		if save_menu == null:
			await _run_dialogue("FileSaved")
			save_menu = preload("res://Assets/Scenes/SaveMenu.tscn").instantiate()
			add_child(save_menu)
			if save_menu:
				save_menu.get_node("o_select").connect("saved", Callable(self, "_on_save_menu_closed"))
		else:
			save_menu.queue_free()
			save_menu = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pp"):
		in_side = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("pp"):
		in_side = false

func _on_save_menu_closed():
	await get_tree().create_timer(0.1).timeout
	Global.can_move = true
	pass


func _run_dialogue(file):
	Global.can_move = false
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/%s.json" % file)
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
	Global.can_move = true
