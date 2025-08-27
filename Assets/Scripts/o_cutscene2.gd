extends Node2D

@onready var cam := $Yamex/Camera
@onready var yamex := $Yamex
@onready var omyx := $Omyx
@onready var sun := $ParallaxBackground/ParallaxLayer2/Sun
@onready var sky := $ParallaxBackground/ParallaxLayer2/Sky2
@onready var ui := $CanvasLayer/Control

var state := 1

func _ready():
	ui.modulate.a = 0
	TranslationServer.set_locale("en")
	_init_scene()
	begin_cutscene()

func _init_scene():
	var overlay := ColorRect.new()
	overlay.color = Color.BLACK
	overlay.modulate.a = 1.0
	overlay.size = get_viewport().size
	add_child(overlay)
	overlay.z_index = 1000

	var t = create_tween()
	t.tween_property(overlay, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(Callable(overlay, "queue_free"))
	await t.finished

	ui.modulate = Color(1,1,1,0)
	var t_ui = create_tween()
	t_ui.tween_property(ui, "modulate:a", 1.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await t_ui.finished

	var t2 = create_tween()
	t2.tween_property(ui, "modulate", Color(1,1,1,1), 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t2.tween_property(ui, "modulate", Color(1,1,1,0), 0.5)
	t2.tween_callback(Callable(ui, "queue_free"))

	create_tween().tween_property(sun, "position", Vector2(125, -40), 69.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	create_tween().tween_property(sky, "modulate", Color(1,1,1,1), 70.75).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func begin_cutscene():
	var t = create_tween()
	t.tween_property(cam, "global_position", Vector2(0, -40), 8.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_callback(Callable(self, "_on_cam_done"))

func _on_cam_done():
	await get_tree().create_timer(0.5).timeout
	execute_state()

func execute_state():
	match state:
		1:
			yamex.position = Vector2(111, 72)
			omyx.position = Vector2(86, 76)
			await _run_dialogue("cutscene_1")
			state = 2
			execute_state()
		2:
			await get_tree().create_timer(1.5).timeout
			await _run_dialogue("cutscene_2")
			state = 3
			execute_state()
		3:
			await get_tree().create_timer(1.5).timeout
			await _run_dialogue("cutscene_3")
			state = 4
			execute_state()
		4:
			$Yamex/Camera.shake(1.5, 0.3)
			await get_tree().create_timer(1.5).timeout
			yamex.position = Vector2(111, 72)
			omyx.position = Vector2(86, 76)
			await _run_dialogue("cutscene_4")
			state = 5
			execute_state()
		5:
			yamex.position.y = 64
			omyx.position.y = 67
			yamex.play("up")
			omyx.play("up")
			yamex.stop()
			omyx.stop()
			await _run_dialogue("cutscene_5")
			omyx.play("down")
			var t = create_tween()
			var tw2 = create_tween()
			var tww3 = create_tween()
			tww3.tween_property($Yamex/Camera, "position", Vector2(-145.098, yamex.position.y - 200), 4)
			tw2.tween_property(yamex, "position", Vector2(111, 280), 13)
			yamex.play("down")
			t.tween_property(omyx, "position", Vector2(86, 270), 3)
			t.tween_property(omyx, "position", Vector2(111, 270), 1)
			await t.finished
			_run_dialogue("cutscene_6")
			state = 6
			execute_state()
		6: 
			omyx.play("up")
			#yamex.play("down")
			#yamex.stop()
			var t = create_tween()
			t.tween_property(omyx, "position", Vector2(111, 190), 3)
			await t.finished
			omyx.stop()
			omyx.animation = "up"
			omyx.play("following")
			yamex.play("nothing")
			_finalize()
			var t2 = create_tween()
			t2.tween_property(omyx, "position", Vector2(97, 650), 6).set_ease(Tween.EASE_IN)
			var t32 = create_tween()
			t32.tween_property(yamex, "position", Vector2(111, 200), 3)
			await t2.finished

func _run_dialogue(file):
	var d = load("res://Assets/oTextboxV5/o_textbox.tscn").instantiate()
	d.offset.y = -340
	add_child(d)
	d.set_dialogue_json("res://Assets/Strings/%s.json" % file)
	await d.dialogue_finished

func _finalize():
	var screen = $CanvasLayer/ColorRect
	screen.visible = true
	screen.modulate.a = 0
	var t = create_tween()
	t.tween_property(screen, "modulate:a", 1.0, 1.5)
	await t.finished
	get_tree().change_scene_to_file("res://Assets/Rooms/farm_2.tscn")
