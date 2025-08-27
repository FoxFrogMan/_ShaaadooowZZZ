extends Node2D

@onready var camera := $Camera2D
@onready var character := $Yamex
var current_condition := 1

func _ready():
	TranslationServer.set_locale("en")
	fade_out_screen(self)
	start_cutscene()
	var tween := create_tween()
			
	tween.tween_property($ParallaxBackground/ParallaxLayer2/Sun, "position", Vector2(125.0, -40), 29.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			
	var tween2 := create_tween()
	tween2.tween_property($ParallaxBackground/ParallaxLayer2/Sky2, "modulate", Color(1,1,1,1), 30.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			


func fade_out_screen(parent: Node):
	var title := $CanvasLayer/Control
	var black_screen := ColorRect.new()
	title.modulate = Color(1,1,1,0)
	black_screen.color = Color.BLACK
	black_screen.size = get_viewport().get_visible_rect().size
	black_screen.position = Vector2.ZERO
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_screen.z_index = 1000
	parent.add_child(black_screen)

	black_screen.modulate.a = 1.0

	var tween := parent.create_tween()
	tween.tween_property(black_screen, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(black_screen, "queue_free"))
	await get_tree().create_timer(1.0).timeout
	var tween2 := parent.create_tween()
	tween2.tween_property(title, "modulate", Color(1,1,1,1), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween2.tween_property(title, "modulate", Color(1,1,1,0), 2.5)
	tween2.tween_callback(Callable(title, "queue_free"))
	



func start_cutscene():
	var tween := create_tween()
	
	tween.tween_property(camera, "global_position", Vector2(0, -40), 8.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(self, "on_camera_arrived"))

func on_camera_arrived():
	await get_tree().create_timer(0.5).timeout
	start(current_condition)
	
	pass



func start(condition := 0):
	match condition:
		1:
			
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			dialogue.set_dialogue("res://Assets/Strings/cutscene_1.json")
			await dialogue.dialogue_finished
			await get_tree().create_timer(1.5).timeout
			current_condition = 2
			await start(current_condition)
		2:
			
			await get_tree().create_timer(1.5).timeout
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			dialogue.set_dialogue("res://Assets/Strings/cutscene_2.json")
			await dialogue.dialogue_finished
			current_condition = 3
			await start(current_condition)
		3:
			await get_tree().create_timer(1.5).timeout
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			dialogue.set_dialogue("res://Assets/Strings/cutscene_3.json")
			await dialogue.dialogue_finished
			current_condition = 4
			await start(current_condition)
		4:
			await get_tree().create_timer(1.5).timeout
			$Omyx.position = Vector2(86, 76)
			$Yamex.position = Vector2(111, 72)
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			dialogue.set_dialogue("res://Assets/Strings/cutscene_4.json")
			await dialogue.dialogue_finished
			current_condition = 5
			await start(current_condition)
		5:
			$Yamex.position = Vector2(111, 64.0)
			$Omyx.position = Vector2(86, 67.0)
			$Yamex.play("up")
			$Omyx.play("up")
			$Yamex.stop()
			$Omyx.stop()
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			dialogue.set_dialogue("res://Assets/Strings/cutscene_5.json")
			await dialogue.dialogue_finished
			$Omyx.play("down")
			var tww = create_tween()
			tww.tween_property($Omyx, "position", Vector2(86, 174), 3)
			tww.tween_property($Omyx, "position", Vector2(111, 174), 0.01)
			
			await tww.finished
			current_condition = 6
			await start(current_condition)
			
			#await get_tree().create_timer(1.2).timeout
			
			#var tween := create_tween()
			#
			#tween.tween_property(camera, "global_position", Vector2(0, 128.0), 2.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
			#tween.tween_callback(Callable(self, "ending"))
		6:
			
			$Omyx.play("up")
			var path = load("res://Assets/DialogueSystem/Dialogue.tscn")
			var dialogue = path.instantiate()
			add_child(dialogue)
			dialogue.offset.y = -340
			$Yamex.play("down")
			$Yamex.stop()
			dialogue.set_dialogue("res://Assets/Strings/cutscene_6.json")
			await dialogue.dialogue_finished
			var tww = create_tween()
			tww.tween_property($Omyx, "position", Vector2(111, 74), 2)
			await tww.finished
			await get_tree().create_timer(2)
			var tww2 = create_tween()
			$Omyx.play("following")
			$Yamex.play("nothing")
			tww2.tween_property($Omyx, "position", Vector2(111, 174), 2)
			await tww2.finished
			ending()
			
			
			
			pass

func ending():
	var black_screen := ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.modulate = Color(1, 1, 1, 0) # شفاف
	black_screen.size = get_viewport().get_visible_rect().size
	black_screen.position = Vector2.ZERO
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_screen.z_index = 1000
	add_child(black_screen)

	var tween := create_tween()
	tween.tween_property(black_screen, "modulate", Color(1, 1, 1, 1), 1.5) # التعتيم
	#tween.tween_callback(Callable(black_screen, "queue_free"))
	await tween.finished
	
	
	pass
