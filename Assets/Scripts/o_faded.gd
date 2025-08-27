extends Node2D

func _ready() -> void:
	Global.o_fade = self
	pass


func _fade(value = 0.0) -> void:
	var black_screen := ColorRect.new()
	black_screen.color = Color.BLACK
	black_screen.size = get_viewport_rect().size
	black_screen.position = Vector2.ZERO
	black_screen.mouse_filter = Control.MOUSE_FILTER_IGNORE
	black_screen.z_index = 1000
	black_screen.modulate.a = 1.0 if value == 0.0 else 0.0
	add_child(black_screen)

	var fade_tween := create_tween()
	fade_tween.tween_property(black_screen, "modulate:a", value, 1.0)
	await fade_tween.finished
