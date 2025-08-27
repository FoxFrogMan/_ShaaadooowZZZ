extends Node2D


var in_side_nove := false
var quest_ref = null
@onready var leader: Marker2D = $Leader
@onready var follower: Marker2D = $Follower
@onready var camera: Camera2D = %camera
@onready var leader_nove: Marker2D = $"../village_lady/Leader"
@onready var follower_nove: Marker2D = $"../village_lady/Follower"
var yes_input = false
var inside_black_smith = false
@onready var leader_smith: Marker2D = $"../BlackSmith/Leader"
@onready var follower_smith: Marker2D = $"../BlackSmith/Follower"

func _start():
	Global.can_move = true
	$"../camera_move".set_process(true)
	
	pass

func _process(delta: float) -> void:
	if in_side_nove:
		if get_parent().get_node("%" + SaveLoader.party[0]).get_node("Sprite").animation == "up" and Input.is_action_just_pressed("confirm") and !get_parent().has_node("o_textbox"):
			Global.can_move = false
			$"../camera_move".set_process(false)
			$"../village_lady/Sprite".play("down")
			var tween_character = create_tween()
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").play("left")
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").play("right")
			tween_character.tween_property(get_node("%" + SaveLoader.party[0]), "position", leader_nove.global_position, 1.0)
			tween_character.parallel().tween_property(get_node("%" + SaveLoader.party[1]), "position", follower_nove.global_position, 1.0)
			await tween_character.finished
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").play("up")
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").play("up")
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").stop()
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").stop()
			var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
			get_parent().add_child(d)
			await get_tree().process_frame
			d.get_node("oTextSystem").connect_to_custom_signal(self, "_on_signal")
			d.name = "o_textbox"
			d.set_dialogue_json("res://Assets/Strings/%s.json" % "MrsNova")
			await d.get_node("oTextSystem").dialogue_finished
			await get_tree().process_frame
			d.queue_free()
			var tween_camera_return = create_tween()
			tween_camera_return.parallel().tween_property(camera, "position", get_parent().get_node("%" + SaveLoader.party[0]).global_position, 1.5)
			await tween_camera_return.finished
			Global.can_move = true
			$"../camera_move".set_process(true)
			if yes_input:
				Global.o_quest._NewQuest("Find a sword and a shield", "Go to the blacksmith and take the bag of coal for Mrs. Nova")
			await get_tree().process_frame
			pass
		
		
	if inside_black_smith:
		if get_parent().get_node("%" + SaveLoader.party[0]).get_node("Sprite").animation == "up" and Input.is_action_just_pressed("confirm") and !get_parent().has_node("o_textbox"):
			Global.can_move = false
			$"../camera_move".set_process(false)
			$"../village_lady/Sprite".play("down")
			var tween_character = create_tween()
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").play("left")
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").play("right")
			tween_character.tween_property(get_node("%" + SaveLoader.party[0]), "position", leader_smith.global_position, 1.0)
			tween_character.parallel().tween_property(get_node("%" + SaveLoader.party[1]), "position", follower_smith.global_position, 1.0)
			await tween_character.finished
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").play("up")
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").play("up")
			get_node("%" + SaveLoader.party[0]).get_node("Sprite").stop()
			get_node("%" + SaveLoader.party[1]).get_node("Sprite").stop()
			var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
			get_parent().add_child(d)
			await get_tree().process_frame
			d.get_node("oTextSystem").connect_to_custom_signal(self, "_on_signal")
			d.name = "o_textbox"
			d.set_dialogue_json("res://Assets/Strings/%s.json" % "BlackSmith")
			await d.get_node("oTextSystem").dialogue_finished
			await get_tree().process_frame
			d.queue_free()
			
			
			
			
			
			
			
			pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	$Area2D.queue_free()
	Global.can_move = false
	var tween_move = create_tween()
	get_node("%" + SaveLoader.party[1]).get_node("Sprite").play("down")
	get_node("%" + SaveLoader.party[0]).get_node("Sprite").play("down")
	tween_move.tween_property(get_node("%" + SaveLoader.party[1]), "position", leader.global_position, 2.5)
	tween_move.parallel().tween_property(get_node("%" + SaveLoader.party[0]), "position", follower.global_position, 2.5)
	await tween_move.finished
	get_node("%" + SaveLoader.party[0]).get_node("Sprite").stop()
	get_node("%" + SaveLoader.party[1]).get_node("Sprite").stop()
	
	move_camera()
	await _run_dialogue("village_lady")
	var tween_camera_return = create_tween()
	tween_camera_return.parallel().tween_property(camera, "position", get_parent().get_node("%" + SaveLoader.party[0]).global_position, 1.5)
	await tween_camera_return.finished
	Global.o_quest._NewQuest("Find a sword and a shield", "Talk to the Village lady")
	Global.can_move = true
	$"../camera_move".set_process(true)
	$"../village_lady/Sprite".play("down")
	
	#quest_ref.complete()
	
	pass # Replace with function body.

func move_camera():
	await get_tree().create_timer(1.5).timeout
	var tween_camera = create_tween()
	get_node("%" + SaveLoader.party[0]).get_node("Sprite").animation = "left"
	get_node("%" + SaveLoader.party[1]).get_node("Sprite").animation = "left"
	tween_camera.parallel().tween_property(camera, "position:x", 665, 1.5)
	$"../camera_move".set_process(false)
	pass


func _run_dialogue(file):
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	add_child(d)
	d.name = "o_textbox"
	d.set_dialogue_json("res://Assets/Strings/%s.json" % file)
	await d.get_node("oTextSystem").dialogue_finished
	d.queue_free()



func _on_signal(signal_name : String, Signal_Data : Dictionary):
	match signal_name:
		"Yes":
			yes_input = true
			$"../village_lady/Area2D".queue_free()
			
		"No":
			pass
	
	pass

func _on_noova_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_side_nove = true
	pass # Replace with function body.


func _on_noova_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		in_side_nove = false
	pass # Replace with function body.


func _on_BlackSmith_body_entered(body: Node2D) -> void:
	inside_black_smith = true
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	inside_black_smith = false
	pass # Replace with function body.
