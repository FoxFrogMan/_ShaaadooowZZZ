extends Node2D

var quest_ref = null
var tween_time := 25.0


func _start():
	%omyx.position = Vector2(440, 255)
	%yamex.position = Vector2(468, 255)
	%omyx.get_node("Sprite").play("down")
	%yamex.get_node("Sprite").play("down")
	var tween_move = create_tween()
	tween_move.tween_property(%omyx, "position:y", 925, tween_time)
	tween_move.parallel().tween_property(%yamex, "position:y", 925, tween_time)
	tween_move.parallel().tween_property(%camera, "position:y", 925, tween_time)
	tween_move.parallel().tween_property(%camera, "zoom", Vector2(6, 6), tween_time/2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	Global.can_move = false
	await Global.o_fade._fade(0.0)
	await get_tree().create_timer(2).timeout
	await _run_dialogue("find_a_sword_&_sield1.cutscene")
	await tween_move.finished
	%omyx.get_node("Sprite").stop()
	%yamex.get_node("Sprite").stop()
	if %camera.global_position != get_node("%" + SaveLoader.party[0]).global_position:
		var tween_camera = create_tween()
		tween_camera.tween_property(%camera, "position", get_node("%" + SaveLoader.party[0]).global_position, 1.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		var tween_camera_reset = create_tween()
		tween_camera_reset.tween_property(%camera, "zoom", Vector2(5, 5), 0.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		await tween_camera.finished
		tween_camera.kill()
		tween_move.kill()
		quest_ref.complete()
		Global.o_quest._NewQuest("Find a sword and a shield", "Search and explore down in the village and try to find some equipment")
	
	
	pass


func _run_dialogue(file):
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	 
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/find_a_sword_&_sield1.cutscene.json")
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()
