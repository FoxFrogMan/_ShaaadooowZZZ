extends Node2D

@onready var runner: AnimatedSprite2D = $Runing
#var move_tween: Tween

@onready var txt = $CanvasLayer/RichTextLabel

var movement_sequence := [
	{"anim": "down", "target": Vector2(268, 73), "duration": 1.5},
	{"anim": "left", "target": Vector2(-30, 73), "duration": 3.0}
]

func _ready() -> void:
	fade_in()
	$AudioStreamPlayer.play(SaveLoader.musicSave1)
	runner.position = Vector2(268, -32)
	perform_movements()
	

func perform_movements() -> void:
	var x = get_tree().create_tween()
	x.tween_property(txt,"modulate",Color.WHITE,3)
	for step in movement_sequence:
		runner.play(step["anim"])
		
		var t := create_tween()
		t.tween_property(runner, "position", step["target"], step["duration"])
		await t.finished
	x = get_tree().create_tween()
	x.tween_property(txt,"modulate:a",0,2)
	await get_tree().create_timer(2).timeout
	await fade_out()
	SaveLoader.musicSave1 = $AudioStreamPlayer.get_playback_position()
	get_tree().change_scene_to_file("res://Assets/Rooms/farm_3.tscn")



func fade_out() -> void:
	var black_screen := ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.size = get_viewport_rect().size
	black_screen.position = Vector2.ZERO
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_screen.z_index = 1000
	black_screen.modulate.a = 0.0
	add_child(black_screen)

	var fade_tween := create_tween()
	fade_tween.tween_property(black_screen, "modulate:a", 1.0, 1.0)
	await fade_tween.finished




func fade_in() -> void:
	var black_screen := ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.size = get_viewport_rect().size
	black_screen.position = Vector2.ZERO
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_screen.z_index = 1000
	black_screen.modulate.a = 1.0
	add_child(black_screen)

	var fade_tween := create_tween()
	fade_tween.tween_property(black_screen, "modulate:a", 0.0, 1.0)
	await fade_tween.finished
